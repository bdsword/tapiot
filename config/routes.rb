Rails.application.routes.draw do
  devise_for :users
  root 'dashboard#show'

  resources :users, only: [:index, :show]

  resources :taps do
    member do
      post 'on', to: 'taps#turn_on'
      post 'off', to: 'taps#turn_off'
      post 'web_on', to: 'taps#web_turn_on'
      post 'web_off', to: 'taps#web_turn_off'
    end
    post 'web_off_update', on: :collection, to: 'taps#web_turn_off_update'
  end

  get 'water_uses', to: 'water_uses#index'
end
