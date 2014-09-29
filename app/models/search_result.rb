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

  def self.from_crossref(id)
    response = SearchCrossref.get "/works/#{id}"
    if response.status == 200
      new response.body["message"], :crossref
    else
      nil
    end
  end

  def self.from_cache(id)
    Rails.cache.fetch(id) do
      from_crossref(id)
    end
  end

  def cache
    Rails.cache.write(@id, self)
  end

  def initialize(data, source = nil)
    @data = data
    source ||= Search.crossref? ? :crossref : :plos

    if source == :crossref
      initialize_crossref
    elsif source == :plos
      initialize_plos
    end
    cache
  end

  def ==(other)
    data == other.data
  end

  # PLOS
  def initialize_plos
    @id = @data["id"]
    @affiliates = @data["affiliate"]
    @article_type = @data["article_type"]
    @authors = @data["author_display"]
    @journal = @data["cross_published_journal_name"]
    @financial_disclosure = @data["financial_disclosure"]
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
    "Published " + publication_date.strftime("%d %b %Y")
  end

  def key
    id
  end

  def subjects
    @subjects || []
  end

  def authors
    @authors.join(", ") if @authors
  end

  def journal
    @journal
  end

  # CrossRef

  def initialize_crossref
    @id = @data["DOI"]
    @title = title_crossref
    @subjects = @data["subject"]
    @type = @data["type"]
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

  def title_crossref
    title = @data["title"].first || @data["container-title"].first || "No title"
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
