class CreateMovieSuggestions < ActiveRecord::Migration[8.0]
  def change
    create_table :movie_suggestions do |t|
      t.integer :tmdb_id
      t.string :title
      t.string :overview
      t.string :poster_url
      t.string :release_date
      t.integer :status
      t.integer :genre_ids, array: true, default: []

      t.timestamps
    end
  end
end
