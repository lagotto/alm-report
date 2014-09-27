
require "csv"
require "set"

# Controller that handles the "Find Articles by DOI/PMID" page.
# TODO: better messaging when users hit the article limit.
class IdController < ApplicationController

  before_filter :set_tabs

  def index
    # doi/pmid page

    article_limit_reached?
  end

  def set_tabs
    @tab = :select_articles
    @title = "Find Articles by DOI/PMID"
    @errors = {}
    @max_doi_field = 8
  end


  # Checks that a given DOI appears to be a well-formed DOI. Note that
  # this method only does a regex match; it does not query any backend to
  # determine if the corresponding article actually exists.
  def self.validate_doi(doi)
    doi =~ %r(\b(10[.][0-9]{4,}(?:[.][0-9]+)*/(?:(?!["&\'<>])\S)+)\b)
    return $1 ? $1 : nil
  end

  # Performs validation of fields from the DOI/PMID form against SOLR.
  # Returns a list of matching solr docs, and populates the @errors field
  # if necessary as a side effect.
  def query_solr_for_ids(field_to_parsed_doi, field_to_parsed_pmid)
    solr_docs = Hash[field_to_parsed_doi.values.map do |doi|
      [doi, SearchResult.from_cache(doi)]
    end]

    field_to_parsed_doi.each do |field, doi|
      if solr_docs[doi].nil?
        @errors[field.to_sym] = "This paper could not be found"
      end
    end

    pmid_docs = SolrRequest.query_by_pmids(field_to_parsed_pmid.values)
    field_to_parsed_pmid.each do |field, pmid|
      doc = pmid_docs[pmid]
      if doc.nil?
        @errors[field.to_sym] = "This paper could not be found"
      else
        solr_docs[doc["id"]] = doc
      end
    end
    solr_docs
  end


  def save
    # if the user is already at the article limit, do not let the user continue
    return render "index" if article_limit_reached?

    # Ignore Errors is an option in the case when the user uploads a file
    # and it contains errors (that is, we get here via process_upload).
    return redirect_to "/preview-list" if params[:commit] == "Ignore Errors"

    # This is totally not the rails way to do validation.  The rails way would
    # do it in the model.  Since we don't have a model for the DOIs that we
    # save to the session, we do it ourselves.  It's made more complicated by
    # the fact that we have two stages of validation, one with a regex and one
    # against solr (and for efficiency, we only want to send DOIs that have
    # passed the regex validation to solr).

    # I tried doing this the rails way, using Report and ReportDoi objects from
    # our model.  This resulted in a wasted day and much pain.  It's made
    # more complicated by the fact that the "Add More Fields" button adds more
    # DOI fields to the form with javascript, which I don't think rails can
    # deal with at all.
    field_to_parsed_doi = {}
    field_to_parsed_pmid = {}
    currents_dois = []
    params.each do |k, v|
      if k.start_with?("doi-pmid-") && !v.empty?
        # PMIDs are numbers
        if v =~ /\A\d+\z/
          field_to_parsed_pmid[k] = Integer(v)
        else
          validated = IdController.validate_doi(v)
          if validated.nil?
            @errors[k.to_sym] = "This DOI is not valid."
          else
            field_to_parsed_doi[k] = validated
          end
        end

        # This is to handle an edge case where the user has clicked on the
        # "Add More Fields" button on the form, and those new fields have
        # errors.  When we re-render the form we need to show all the fields.
        field_num = k[("doi-pmid-".length)..(k.length)].to_i
        @max_doi_field = field_num > @max_doi_field ? field_num : @max_doi_field
      end
    end

    # Now, for all the identifiers that passed regex validation, query against solr.
    solr_docs = query_solr_for_ids(field_to_parsed_doi, field_to_parsed_pmid)
    if @errors.length == 0

      # We don't have a publication date for currents articles, so just use
      # the order they were added to the form instead.
      currents_dois.each_with_index {|doi, i| @cart[doi] = i}
      solr_docs.each {|_, doc| @cart[doc.id] = doc}
      redirect_to "/preview-list"
    else
      render "index"
    end
  end


  def upload
    @title = "Upload File"

    article_limit_reached?
  end


  # Parses the uploaded DOI file, which will be something that looks like
  # a CSV with only one entry/row.
  def parse_file(contents)
    results = []
    CSV.parse(contents.read) do |row|
      test = row[0].downcase

      # Handle the header row.
      if test != "doi" && test != '"doi"'
        results << row[0]
      end
    end
    results
  end


  def process_upload
    # if the user is already at the article limit, do not let the user continue
    return render "upload" if article_limit_reached?

    if params[:"upload-file-field"].nil?
      @file_absent = true
      render "upload"
      return
    end
    ids = parse_file(params[:"upload-file-field"])
    valid_dois = []
    valid_pmids = []

    # In order to re-use parts of the DOI input form for upload errors, we create
    # form field names for each error.
    error_index = 1
    add_error = lambda { |id, error_message|
      error_field = "doi-pmid-#{error_index}".intern
      error_index += 1
      @errors[error_field] = error_message
      params[error_field] = id
    }

    ids.each do |id|
      id = id.strip
      if id.length > 0
        begin
          valid_pmids << Integer(id)
        rescue ArgumentError
          validated = IdController.validate_doi(id)
          if validated.nil?
            add_error.call(id, "This DOI/PMID is not a PLOS article")
          else
            valid_dois << validated
          end
        end
      end
    end

    valid_dois.each do |doi|
      doc = SearchResult.from_cache(doi)
      if doc.nil?
        add_error.call(doi, "This paper could not be found")
      else
        @cart[doc.id] = doc
      end
    end

    pmid_docs = SolrRequest.query_by_pmids(valid_pmids)
    valid_pmids.each do |pmid|
      doc = pmid_docs[pmid]
      if doc.nil?
        add_error.call(pmid, "This paper could not be found")
      else
        @cart[doc.id] = doc
      end
    end

    if @errors.length > 0
      @num_valid_dois = @cart.size
      render "fix_errors"
    else
      redirect_to "/preview-list"
    end
  end

end
