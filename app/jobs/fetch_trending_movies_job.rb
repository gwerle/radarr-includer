class FetchTrendingMoviesJob < ApplicationJob
  queue_as :default

  POSTER_BASE_URL = "https://image.tmdb.org/t/p/w500".freeze

  def perform(tmdb = TmdbClient.new)
    tmdb.popular.each do |movie|
      MovieSuggestion.create_with(
        title: movie["title"],
        overview: movie["overview"],
        poster_url: movie["poster_path"] && "#{POSTER_BASE_URL}#{movie["poster_path"]}",
        release_date: movie["release_date"],
        genre_ids: movie["genre_ids"],
        status: :pending
      ).find_or_create_by(tmdb_id: movie["id"])
    end
  end
end
