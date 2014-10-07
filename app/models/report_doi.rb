class ReportDoi < ActiveRecord::Base
  belongs_to :report
  attr_accessible :doi, :sort_order
  attr_accessor :solr, :alm, :display_index

  def alm
    @alm || {}
  end

  def to_csv
    if alm && solr
      row = [
        doi,
        solr.pmid,
        solr.publication_date,
        solr.title,
        solr.authors,
        solr.affiliates.try(:join, "; ")
      ]

      AlmRequest.ALM_METRICS.keys.each do |metric|
        row.push(alm[metric])
      end

      row += [
        solr.journal,
        solr.article_type,
        solr.financial_disclosure,
        subject_string,
        solr.received_date,
        solr.accepted_date,
        solr.editors.try(:join, ", "),
        "http://dx.doi.org/#{doi}"
      ]
      # Some of the long free-form text fields can contain newlines; convert
      # these to spaces.
      row.map do |field|
        field.is_a?(String) ? field.try(:gsub, "\n", " ") : field
      end
    end
  end

  private

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
