require "test_helper"

class FetchTrendingMoviesJobTest < ActiveJob::TestCase
  class FakeTmdb
    def popular
      [ {
        "id" => 1,
        "title" => "Spider-Man: Brand New Day",
        "overview" => "Peter is back",
        "poster_path" => "/poster.jpg",
        "release_date" => "2026-07-31",
        "genre_ids" => [ 28 ]
      } ]
    end
  end

  test "creates pending suggestions and skips already known tmdb ids" do
    FetchTrendingMoviesJob.new.perform(FakeTmdb.new)

    movie = MovieSuggestion.find_by!(tmdb_id: 1)
    assert movie.pending?
    assert_equal "https://image.tmdb.org/t/p/w500/poster.jpg", movie.poster_url
    assert_equal [ "Action" ], movie.genre_names

    assert_no_difference("MovieSuggestion.count") do
      FetchTrendingMoviesJob.new.perform(FakeTmdb.new)
    end
  end
end
