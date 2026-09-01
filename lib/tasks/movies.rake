namespace :movies do
  desc "Search popular movies on TMDB"
  task fetch_trending: :environment do
    TMDB_API_KEY = ENV.fetch("TMDB_API_KEY")
    TOTAL_FETCH_PAGES = 2

    (1..TOTAL_FETCH_PAGES).each do |page|
      response = Faraday.get("https://api.themoviedb.org/3/trending/movie/day?api_key=#{TMDB_API_KEY}&page=#{page}")
      movies = JSON.parse(response.body)["results"]

      movies.each do |movie_data|
        MovieSuggestion.create_or_find_by(tmdb_id: movie_data["id"]) do |m|
          m.title = movie_data["title"]
          m.overview = movie_data["overview"]
          m.poster_url = movie_data["poster_path"]
          m.genre_ids = movie_data["genre_ids"]
          m.release_date = movie_data["release_date"]
          m.status = :pending
        end
      end
    end
  end
end
