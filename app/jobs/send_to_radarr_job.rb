class SendToRadarrJob < ApplicationJob
  queue_as :default

  def perform(movie_suggestion_id, radarr = RadarrClient.new)
    movie = MovieSuggestion.find(movie_suggestion_id)
    match = radarr.lookup(movie.title).first

    if match.nil?
      movie.failed!
      raise "No Radarr match for #{movie.title}"
    end

    response = radarr.add_movie(format_payload(match))

    if response.success?
      movie.in_radarr!
    else
      movie.failed!
      raise "Fail to send to radarr: #{response.body}"
    end
  end

  private

  def format_payload(match)
    match.merge(
      "rootFolderPath" => "/movies",
      "addOptions" => { "monitor" => "movieOnly", "searchForMovie" => true },
      "qualityProfileId" => 4,
      "monitored" => true
    )
  end
end
