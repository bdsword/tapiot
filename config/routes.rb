Rails.application.routes.draw do
  devise_for :users
  root 'taps#index'
  resources :taps
end
