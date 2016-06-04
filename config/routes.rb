Rails.application.routes.draw do
  devise_for :users
  root 'taps#index'

  resources :taps do
    member do
      post 'on', to: 'taps#turn_on'
      post 'off', to: 'taps#turn_off'
    end
  end

  resources :users, only: [:index, :show]
end
