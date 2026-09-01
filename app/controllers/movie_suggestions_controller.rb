class MovieSuggestionsController < ApplicationController
  def index
    render json: MovieSuggestion.pending.as_json(methods: :genre_names), status: :ok
  end

  def lookup
    return render json: [], status: :ok if params[:term].blank?

    render json: RadarrClient.new.lookup(params[:term]), status: :ok

  rescue RadarrClient::Error => e
    render json: { error: e.message }, status: :bad_gateway
  end

  def accept
    movie = MovieSuggestion.find(params[:id])
    movie.accepted!

    SendToRadarrJob.perform_later(movie.id)

    render json: { message: "Movie sent to Radarr", movie_id: movie.id }, status: :ok

  rescue ActiveRecord::RecordNotFound
    render json: { error: "Movie not found" }, status: :not_found
  end

  def reject
    movie = MovieSuggestion.find(params[:id])
    movie.rejected!

    render json: { message: "Movie rejected", movie_id: movie.id }, status: :ok

  rescue ActiveRecord::RecordNotFound
    render json: { error: "Movie not found" }, status: :not_found
  end
end
