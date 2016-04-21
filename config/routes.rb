Rails.application.routes.draw do
  resources :users do
    resources :api_keys
  end
end
