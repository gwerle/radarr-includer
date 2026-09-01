require "test_helper"

class SendToRadarrJobTest < ActiveJob::TestCase
  class FakeRadarr
    attr_reader :posted

    def initialize(matches, status: 201)
      @matches = matches
      @status = status
    end

    def lookup(_term) = @matches

    def add_movie(payload)
      @posted = payload
      Faraday::Response.new(Faraday::Env.from(status: @status, body: ""))
    end
  end

  test "builds a radarr payload from the lookup match" do
    movie = MovieSuggestion.create!(tmdb_id: 1, title: "Spider-Man: Brand New Day", status: :accepted)
    radarr = FakeRadarr.new([ { "tmdbId" => 1, "qualityProfileId" => 4 } ])

    SendToRadarrJob.new.perform(movie.id, radarr)

    assert_equal "/movies", radarr.posted["rootFolderPath"]
    assert_equal 4, radarr.posted["qualityProfileId"]
    assert_equal({ "monitor" => "movieOnly", "searchForMovie" => true }, radarr.posted["addOptions"])
    assert movie.reload.in_radarr?
  end

  test "marks the movie as failed when radarr has no match" do
    movie = MovieSuggestion.create!(tmdb_id: 2, title: "Unknown", status: :accepted)

    assert_raises(RuntimeError) { SendToRadarrJob.new.perform(movie.id, FakeRadarr.new([])) }

    assert movie.reload.failed?
  end
end
