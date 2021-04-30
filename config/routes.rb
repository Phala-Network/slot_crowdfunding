# frozen_string_literal: true

Rails.application.routes.draw do
  resources :campaigns, only: %i[index show] do
    scope module: :campaigns do
      resources :contributors, only: %i[index show]
      resources :contributions, only: %i[index]

      resource :referrer, only: %i[update]
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
