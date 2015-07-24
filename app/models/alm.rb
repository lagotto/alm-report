# Interface to the ALM API.
class Alm
  include Pageable

  ALM_METRICS = {
    plos_total: "PLOS Total",
    plos_html: "PLOS views",
    plos_pdf: "PLOS PDF downloads",
    plos_xml: "PLOS XML downloads",
    pmc_total: "PMC Total",
    pmc_views: "PMC views",
    pmc_pdf: "PMC PDF Downloads",
    crossref: "CrossRef",
    scopus: "Scopus",
    pubmed: "PubMed Central",
    citeulike: "CiteULike",
    mendeley: "Mendeley",
    twitter: "Twitter",
    facebook: "Facebook",
    wikipedia: "Wikipedia",
    researchblogging: "Research Blogging",
    nature: "Nature Blogs",
    scienceseeker: "Science Seeker",
    datacite: "DataCite",
    pmceurope: "PMC Europe Citations",
    pmceuropedata: "PMC Europe Database Citations",
    wos: "Web of Science",
    reddit: "Reddit",
    wordpress: "Wordpress.com",
    figshare: "Figshare",
    f1000: "F1000Prime",
  }

  MAX_PER_REQUEST = ENV["ALM_MAX_WORKS_PER_REQUEST"].to_i

  def self.conn
    @conn ||= Faraday.new(url: ENV["ALM_URL"]) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.response :json
      faraday.adapter  Faraday.default_adapter
    end
  end

  def self.get_v5(dois)
    request = {
      api_key: ENV["ALM_API_KEY"],
      ids: dois.sort,
    }

    paginate(request, array: :ids, per_page: MAX_PER_REQUEST) do |request|
      request[:ids] = request[:ids].join(",")
      # To get Mendeley countries data for single work visualization
      request[:info] = "detail" if dois.length == 1

      response = conn.get("/api/v5/articles", request).body
    end
  end

  # Retrieves and returns all ALM data for the given DOIs. Multiple requests to ALM
  # may be made if the number of DOIs is large. The returned list is the raw JSON
  # output from ALM, with no additional processing.
  def self.get_raw_data(dois)
    request = {
      api_key: ENV["ALM_API_KEY"],
      ids: dois.sort
    }

    result = paginate(request, array: :ids, per_page: MAX_PER_REQUEST) do |request|
      params = request.dup
      params[:ids] = request[:ids].join(",")

      response = conn.get("/api/v3/articles", params)

      if response.status != 200
        Rails.logger.error "ALM (#{response.env.url}) returned #{response.status}"
        next
      end
      response.body
    end
    result || []
  end

  # Checks memcache to see if data about the given DOIs are present.
  #
  # Params:
  #   dois: list of DOIs to check
  #   cache_results: dict that will be filled with results from the cache.  The
  #     key will be doi, and the value the result found in the cache.
  #   cache_suffix: the suffix to append to the DOI to generate a cache key
  #
  # Returns: all DOIs that were *not* found in the cache
  def self.check_cache(dois, cache_results, cache_suffix)
    dois.delete_if  do | doi |
      results = Rails.cache.read("#{doi}.#{cache_suffix}")
      if results
        cache_results[doi] = results
        true
      end
    end
    dois
  end


  # Returns a dict containing ALM usage data for a given list of works.
  def self.get_data_for_works(report_dois)
    all_results = {}
    dois = report_dois.map { |report_doi| report_doi.doi }

    # get alm data from cache
    dois = check_cache(dois, all_results, "alm")

    json = get_raw_data(dois)
    json.each do |work|
      sources = work["sources"].map do |source|
        [source["name"], source["metrics"]]
      end.flatten(1)

      sources_dict = Hash.new({}).merge(Hash[*sources])

      results = {}

      totals = Hash[
        %i(pubmed crossref scopus datacite pmceurope pmceuropedata
          wos citeulike mendeley figshare nature researchblogging
          scienceseeker facebook twitter wikipedia reddit wordpress
          f1000
        ).map do |source|
          [source, get_source_total(sources_dict, source.to_s)]
        end
      ]

      results.merge!(totals)

      results[:plos_html] = sources_dict["counter"]["html"].to_i
      results[:plos_pdf] = sources_dict["counter"]["pdf"].to_i
      results[:plos_xml] = sources_dict["counter"]["total"].to_i - (results[:plos_html] + results[:plos_pdf])
      results[:plos_total] = get_source_total(sources_dict, "counter")

      results[:pmc_views] = sources_dict["pmc"]["html"].to_i
      results[:pmc_pdf] = sources_dict["pmc"]["pdf"].to_i
      results[:pmc_total] = results[:pmc_views] + results[:pmc_pdf]

      results[:total_usage] = results[:plos_html] + results[:plos_pdf] +
        results[:plos_xml] + results[:pmc_views] + results[:pmc_pdf]

      results[:viewed_data_present] = (results[:total_usage] > 0)

      results[:cited_data_present] = (results[:pubmed] + results[:crossref] +
        results[:scopus] + results[:datacite] + results[:pmceurope] +
        results[:pmceuropedata] + results[:wos]) > 0

      results[:saved_data_present] = (results[:citeulike] + results[:mendeley] +
        results[:figshare]) > 0

      results[:discussed_data_present] = (results[:nature] +
        results[:researchblogging] + results[:scienceseeker] +
        results[:facebook] + results[:twitter] + results[:wikipedia] +
        results[:reddit] + results[:wordpress]) > 0

      results[:recommended_data_present] = results[:f1000] > 0

      all_results[work["doi"]] = results

      # store alm data in cache
      Rails.cache.write("#{work["doi"]}.alm", results, :expires_in => 1.day)
    end
    all_results
  end

  # Returns the total for the given ALM source, or zero if the source (or its total
  # attribute) is not present.
  def self.get_source_total(sources_dict, source_name)
    source = sources_dict[source_name]
    if source.nil?
      0
    else
      source["total"].nil? ? 0 : source["total"].to_i
    end
  end

  # Retrieves work data from ALM suitable for display in a brief list, such
  # as search results or the preview list.
  def self.get_work_data_for_list_display(dois)
    results = {}
    dois = check_cache(dois, results, "alm_list_display")
    json = get_raw_data(dois)
    json.each do |work|
      results[work["doi"]] = work
      Rails.cache.write("#{work["doi"]}.alm_list_display", work, :expires_in => 1.day)
    end
    results
  end

  # Gathers ALM data for visualization for a given list of dois
  # If the list of dois exceed certain size, the data will be retrieved from solr
  # (for performance reasons)
  #

  # get data for single work visualization report
  def self.get_data_for_one_work(report_dois)
    dois = report_dois.map { |report_doi| report_doi.doi }

    params = {}
    params[:ids] = dois.join(",")
    params[:info] = "history"
    params[:source] = "crossref,pubmed,scopus"

    url = get_alm_url(params)

    resp = Net::HTTP.get_response(URI.parse(url))

    all_results = {}

    if !resp.kind_of?(Net::HTTPSuccess)
      Rails.logger.error "ALM Server for #{url} returned #{resp.code}: " + resp.body

      return all_results
    end

    data = JSON.parse(resp.body)

    data.each do | work |
      results = {}

      results = work["sources"].inject({}) do | result, source |
        key = source["name"].to_sym
        result[key] = {}
        result[key][:total] = source["metrics"]["total"].to_i
        result
      end

      results[:publication_date] = work["publication_date"]

      all_results[work["doi"]] = results
    end

    params = {}
    params[:ids] = dois.join(",")
    params[:info] = "event"
    params[:source] = "counter,pmc,citeulike,twitter,researchblogging,nature,scienceseeker,mendeley"

    url = get_alm_url(params)

    resp = Net::HTTP.get_response(URI.parse(url))

    if !resp.kind_of?(Net::HTTPSuccess)
      Rails.logger.error "ALM Server for #{url} returned #{resp.code}: " + resp.body

      return all_results
    end

    data = JSON.parse(resp.body)

    data.each do | work |
      results = all_results[work["doi"]]

      work["sources"].inject(results) do | result, source |
        key = source["name"].to_sym
        result[key] = {}
        result[key][:events] = source["events"]
        result[key][:total] = source["metrics"]["total"].to_i
        result
      end

      all_results[work["doi"]] = results
    end

    return all_results
  end

  # Params are the parameters to be used to query for alm data
  def self.get_alm_url(params)
    url = ""
    if (!params.nil? && params.length > 0)
      url = "#{ENV["ALM_URL"]}/api/v3/articles?api_key=#{ENV["ALM_API_KEY"]}&#{params.to_param}"
    end
    return url
  end
end
