class SearchResult
  attr_accessor :checked
  attr_reader :affiliates, :article_type, :cross_published_journal_name,
    :data, :financial_disclosure, :id, :pmid, :publication_date, :subjects,
    :title

  def initialize(data)
    @data = data
    if Search.plos?
      initialize_plos
    elsif Search.crossref?
      initialize_crossref
    end
  end

  def initialize_plos
    @affiliates = @data["affiliate"]
    @article_type = @data["article_type"]
    @authors = @data["author_display"]
    @cross_published_journal_name = @data["cross_published_journal_name"]
    @financial_disclosure = @data["financial_disclosure"]
    @id = @data["id"]
    @pmid = @data["pmid"]
    @publication_date = @data["publication_date"]
    @subjects = @data["subject"]
    @title = @data["title"]
  end

  def initialize_crossref
  end

  def detail_displayed
    !!authors
  end

  def published
    start = if detail_displayed
      " | published "
    else
      "Published "
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
end
