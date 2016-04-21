Rails.application.routes.draw do
  namespace :api do
    get :test, to: 'test#index'
  end
  resources :users do
    resources :api_keys
  end
end
