Rails.application.routes.draw do
  # Health check for kamal-proxy (must come before the '(/:sort)' catch-all).
  get "up" => "rails/health#show", as: :rails_health_check

  resources :tasks do
    member do
      post :toggle
    end
  end
  # Public sign-up is disabled; users are created via the Rails console.
  # Keep only the signed-in "edit account" routes from registrations.
  devise_for :users, skip: [ :registrations ]
  devise_scope :user do
    get   "users/edit", to: "devise/registrations#edit",   as: :edit_user_registration
    patch "users",      to: "devise/registrations#update", as: :user_registration
    put   "users",      to: "devise/registrations#update"
  end
  get "(/:sort)", to: "tasks#index"
  root "tasks#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
