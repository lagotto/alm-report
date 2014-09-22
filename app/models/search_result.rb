class SearchResult
  attr_accessor :checked
  attr_reader :affiliates, :article_type, :cross_published_journal_name,
              :data, :financial_disclosure, :id, :pmid, :publication_date,
              :subjects, :title, :type, :publisher

  # CrossRef types
  # "proceedings","reference-book","journal-issue","proceedings-article",
  # "other","dissertation","dataset","edited-book","journal-article","journal",
  # "report","book-series","report-series","book-track","standard",
  # "book-section","book-part","book","book-chapter","standard-series",
  # "monograph","component","reference-entry","journal-volume","book-set"

  def initialize(data)
    @data = data
    if Search.plos?
      initialize_plos
    elsif Search.crossref?
      initialize_crossref
    end
  end

  # PLOS
  def initialize_plos
    @affiliates = @data["affiliate"]
    @article_type = @data["article_type"]
    @authors = @data["author_display"]
    @journal = @data["cross_published_journal_name"]
    @financial_disclosure = @data["financial_disclosure"]
    @id = @data["id"]
    @pmid = @data["pmid"]
    @publication_date = @data["publication_date"]
    @subjects = @data["subject"]
    @title = @data["title"]
    @type = "journal-article"
  end

  def detail_displayed
    !!authors
  end

  def published
    if detail_displayed
      start = " | published "
    else
      start = "Published "
    end
    start + publication_date.strftime("%d %b %Y")
  end

  def key
    "#{id}|#{publication_date.strftime("%s")}"
  end

  def authors
    @authors.join(", ") if @authors
  end

  def journal
    cross_published_journal_name.first
  end

  # CrossRef

  def initialize_crossref
    @title = @data["title"].first
    @subjects = @data["subject"]
    @type = @data["type"]
    @id = @data["DOI"]
    @publication_date = published_crossref
    if @data["author"]
      @authors = @data["author"].map do |author|
        "#{author["given"]} #{author["family"]}"
      end
    end
    @journal = @data["container-title"].join
    @url = @data["URL"]
    @publisher = @data["publisher"]
  end

  def published_crossref
    date = if @data["issued"]["date-parts"].first.compact.present?
      @data["issued"]["date-parts"]
    else
      @data["deposited"]["date-parts"]
    end
    DateTime.new(*date.first)
  end
end
