Rails.application.routes.draw do
  root 'home#index'
  get '/auth/:provider/callback', to: 'users#log_in'
  get '/auth/failure',            to: 'users#failure'
  post '/log_out',                to: 'users#log_out'
  post '/users',                  to: 'users#index'
  resources :users, only: [:index, :destroy, :show, :edit, :update]
end
