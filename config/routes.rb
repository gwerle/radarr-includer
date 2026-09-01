require "sidekiq/web"
require "sidekiq/cron/web"

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  ActiveSupport::SecurityUtils.secure_compare(user, ENV.fetch("SIDEKIQ_USER")) &
    ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch("SIDEKIQ_PASSWORD"))
end

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :movie_suggestions, only: [ :index ] do
    collection do
      get :lookup
      post :fetch_trending
    end
    member do
      patch :accept
      patch :reject
    end
  end

  root "movie_suggestions#index"
end
