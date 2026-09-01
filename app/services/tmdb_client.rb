class TmdbClient
  class Error < StandardError; end

  def initialize(api_key: ENV.fetch("TMDB_API_KEY"))
    @connection = Faraday.new(
      url: "https://api.themoviedb.org/3",
      params: { api_key: api_key }
    )
  end

  def popular
    response = @connection.get("movie/popular")
    raise Error, "TMDB popular fetch failed: #{response.body}" unless response.success?

    JSON.parse(response.body)["results"]
  end
end
