class RadarrClient
  class Error < StandardError; end

  def initialize(url: ENV.fetch("RADARR_URL"), api_key: ENV.fetch("RADARR_API_KEY"))
    @connection = Faraday.new(
      url: url,
      headers: { "X-Api-Key" => api_key, "Content-Type" => "application/json" }
    )
  end

  # Returns the Radarr matches for a search term, most relevant first.
  def lookup(term)
    response = @connection.get("/api/v3/movie/lookup", { term: term })
    raise Error, "Lookup failed for #{term}: #{response.body}" unless response.success?

    JSON.parse(response.body)
  end

  def add_movie(payload)
    @connection.post("/api/v3/movie", payload.to_json)
  end
end
