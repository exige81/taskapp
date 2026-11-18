Rails.application.routes.draw do
  # Health check for kamal-proxy (must come before the '(/:sort)' catch-all).
  get "up" => "rails/health#show", as: :rails_health_check

  resources :tasks do
    member do
      post :toggle
    end
  end
  # Sign in/out. There is no public sign-up; users are created via the Rails console.
  resource :session, only: %i[ new create destroy ]
  # Signed-in user can change their email/password at /account/edit
  resource :account, only: %i[ edit update ]
  get "(/:sort)", to: "tasks#index"
  root "tasks#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
