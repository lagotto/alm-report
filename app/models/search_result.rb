class SearchResult
  attr_accessor :checked
  attr_reader :article_type, :cross_published_journal_name,
              :data, :financial_disclosure, :id, :pmid, :publication_date,
              :subjects, :title, :type, :publisher, :journal, :editors,
              :received_date, :accepted_date

  def self.from_crossref(id)
    response = SearchCrossref.get "/works/#{id}"
    if response.status == 200
      new response.body["message"], :crossref
    else
      nil
    end
  end

  def self.from_cache(id)
    Search.find_by_ids([id]).first
  end

  def cache
    Rails.cache.write("Search:" + @id, self)
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
    @affiliations = @data["affiliate"]
    @article_type = @data["article_type"]
    @authors = @data["author_display"]
    @editors = @data["editor_display"]
    @journal = @data["cross_published_journal_name"].try(:flatten).try(:at, 0)
    @financial_disclosure = @data["financial_disclosure"]
    @pmid = @data["pmid"]
    @publication_date = @data["publication_date"]
    @received_date = @data["received_date"]
    @accepted_date = @data["accepted_date"]
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

  def affiliations
    if @affiliations
      affiliations = @affiliations.map do |a|
        fields = Geocode.parse_location_from_affiliation(a)
        if fields
          {
            full: a,
            address: fields[0],
            institution: fields[1]
          }
        else
          nil
        end
      end.compact

      locations = Geocode.load_from_addresses(
        affiliations.map{ |a| a[:address] }.uniq
      )

      if locations
        affiliations.map do |a|
          located = locations.find do |address, location|
            address == a[:address].downcase
          end
          if located
            a.update(location: {
              lat: located[1].latitude,
              lng: located[1].longitude
            })
          end
        end
      end
    end
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
    @journal = journal_crossref
    @url = @data["URL"]
    @publisher = @data["publisher"]
  end

  def journal_crossref
    @data["container-title"].sort_by(&:length).last
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
