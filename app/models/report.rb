require 'csv'

class Report < ActiveRecord::Base
  attr_accessible :user_id

  # TODO: figure out what we want the default sort order to be.
  # doi is likely not a good solution.
  has_many :report_dois, :order => 'sort_order'


  # Creates a child ReportDoi object for each DOI passed in in the input array.
  # Sort order is determined by the position in the array.  This object must have
  # already been saved to the DB before this method is called.
  def add_all_dois(dois)

    # Since reports can have many DOIs, for performance we do a batch insert.
    # Active Record won't do this on its own.
    report_dois = dois.map.with_index do |doi, index|
      {
        doi: doi,
        sort_order: index
      }
    end
    self.report_dois.create(report_dois)

    # TEMP DISABLE, PRETTY BAD.
    # sql = "INSERT report_dois(doi, report_id, sort_order, created_at, updated_at) VALUES "
    # dois.each_with_index {|doi, i| sql << "('#{doi}', #{self.id}, #{i}, NOW(), NOW()), "}
    # sql[-2] = ";"
    # self.connection.execute(sql)
  end


  # Sets the @sorted_report_dates field.
  # Precondition: load_articles_from_solr has already been called.
  def sort_report_dates
    if @sorted_report_dates.nil?
      @sorted_report_dates = report_dois.collect{|report_doi| report_doi.solr.publication_date}
      @sorted_report_dates.sort!
    end
  end
  private :sort_report_dates


  # Returns the earliest publication date of any article in this report.
  # Precondition: load_articles_from_solr has already been called.
  def get_earliest_report_date
    sort_report_dates
    @sorted_report_dates[0]
  end


  # Returns the latest publication date of any article in this report.
  # Precondition: load_articles_from_solr has already been called.
  def get_latest_report_date
    sort_report_dates
    @sorted_report_dates[-1]
  end

  def to_csv(options = {})
    field = options[:field]

    if (field.nil?)
      alm = AlmRequest.get_data_for_articles(report_dois)

      data = report_dois.map do |report_doi|
        report_doi.solr = SearchResult.from_cache(report_doi.doi)
        report_doi.alm = alm[report_doi.doi]
      end

      CSV.generate({ :force_quotes => true }) do | csv |
        title_row = [
            "DOI", "PMID", "Publication Date", "Title", "Authors", "Author Affiliations",
            ]
        title_row += AlmRequest.ALM_METRICS.values
        title_row += [
            "Journal", "Article Type", "Funding Statement", "Subject Areas", "Submission Date",
            "Acceptance Date", "Editors", "Article URL",
            ]
        csv << title_row

        report_dois.each do |report_doi|
          # If the article was unpublished (rare), skip it.
          row = report_doi.to_csv
          csv << row if row
        end
      end
    elsif (field == "doi")
      CSV.generate({ :force_quotes => true}) do | csv |
        csv << ["DOI"]

        report_dois.each do | report_doi |
          csv << [report_doi.doi]
        end
      end
    end
  end

  def has_alm?
    report_dois.index{|r| r.alm.present? }.present?
  end
end
