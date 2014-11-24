class ReportDoi < ActiveRecord::Base
  belongs_to :report
  attr_accessor :solr, :alm, :display_index

  def alm
    @alm || {}
  end

  def to_csv
    if alm && solr
      alm_columns = AlmRequest::ALM_METRICS.keys.map { |metric| alm[metric] }
      row = csv_row.insert(6, *alm_columns)
      # Some of the long free-form text fields can contain newlines; convert
      # these to spaces.
      row.map do |field|
        field.is_a?(String) ? field.try(:gsub, "\n", " ") : field
      end
    end
  end

  private

  def csv_row
    [
      doi,
      solr.pmid,
      solr.publication_date,
      solr.title,
      solr.authors,
      solr.affiliations.try(:join, "; "),
      # Here be ALM data
      solr.journal,
      solr.article_type,
      solr.financial_disclosure,
      subject_string,
      solr.received_date,
      solr.accepted_date,
      solr.editors.try(:join, ", "),
      "http://dx.doi.org/#{doi}"
    ]
  end

  # Returns a string suitable for inclusion in the CSV report for subject areas
  # of an article.  Only "leaf" or lowest-level categories are included.  The
  # input is the list of subjects as returned by solr.
  def subject_string
    # We sort on the leaf categories, just like ambra does.
    solr.subjects.map do |subject|
      subject.split("/")[-1]
    end.sort.uniq.join(",")
  end
end
