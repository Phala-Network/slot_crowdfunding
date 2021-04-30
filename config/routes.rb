# frozen_string_literal: true

Rails.application.routes.draw do
  resources :campaigns, only: %i[index show] do
    scope module: :campaigns do
      resources :contributors, only: %i[index show]
      resources :contributions, only: %i[index]
      resources :announcements, only: %i[index]
      resources :competitors, only: %i[index]
    end
  end

  resources :coin_market_charts, only: %i[show]

  get "ping", to: "home#ping"

  # root to: "home#index"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
