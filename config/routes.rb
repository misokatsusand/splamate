Rails.application.routes.draw do
  root 'home#index'
  get '/auth/:provider/callback', to: 'users#log_in'
  get '/auth/failure',            to: 'users#failure'
end
