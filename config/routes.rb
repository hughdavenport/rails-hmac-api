Rails.application.routes.draw do
  get 'api/last_nonce', to: 'api#last_nonce'
  namespace :api do
    get :test, to: 'test#index'
  end
  resources :users do
    resources :api_keys
  end
end
