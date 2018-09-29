Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users
  root to: 'activity#index'

  namespace :api, defaults: { format: :json } do
    post :user_access_token, to: 'authentication#user_access_token'
    # post :forgot_password, to: 'authentication#forgot_password'
  end
end
