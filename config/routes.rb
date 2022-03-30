Rails.application.routes.draw do
  post '/auth/:provider/callback', to: 'users#twitter_auth'
  get '/auth/failure',             to: 'users#failure'
end
