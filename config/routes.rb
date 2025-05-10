require 'sidekiq/web'
Rails.application.routes.draw do
  resources :users, only: [:create, :index]
  post 'users/login', to: 'users#login'
  post 'users/change_password', to: 'users#change_password'
  get 'users/profile', to: 'users#profile'
  delete 'users', to: 'users#destroy'
  put 'users', to: 'users#update'

  get 'posts/my_posts', to: 'posts#my_posts'
  get 'authors/:author_id/posts', to: 'posts#by_author'

  resources :posts do
    resources :comments, only: [:create, :update, :destroy]
    resources :tags, only: [:create, :update, :destroy]
  end

  mount Sidekiq::Web => "/sidekiq"


  get "up" => "rails/health#show", as: :rails_health_check
end
