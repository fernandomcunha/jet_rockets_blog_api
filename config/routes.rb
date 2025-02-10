Rails.application.routes.draw do
  namespace :api do
    resources :posts, only: [:create]
    resources :ratings, only: [:create]

    get 'top_posts', to: 'posts#top_posts'
    get 'ips', to: 'posts#ips'
  end
end
