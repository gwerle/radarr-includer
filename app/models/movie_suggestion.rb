class MovieSuggestion < ApplicationRecord
  enum :status, { pending: 0, accepted: 1, rejected: 2, in_radarr: 3, failed: 4 }

  TMDB_GENRES = {
    28 => "Action",
    12 => "Abenteuer",
    16 => "Animation",
    35 => "Komödie",
    80 => "Krimi",
    99 => "Dokumentarfilm",
    18 => "Drama",
    10751 => "Familie",
    14 => "Fantasy",
    36 => "Historie",
    27 => "Horror",
    10402 => "Musik",
    9648 => "Mystery",
    10749 => "Liebesfilm",
    878 => "Science Fiction",
    10770 => "TV-Film",
    53 => "Thriller",
    10752 => "Kriegsfilm",
    37 => "Western"
  }.freeze

  def genre_names
    genre_ids.map { |id| TMDB_GENRES[id] }.compact
  end

  validates :tmdb_id, uniqueness: true
end
