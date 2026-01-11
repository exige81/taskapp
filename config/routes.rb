Rails.application.routes.draw do
  resources :tasks do
    member do
      post :toggle
    end
  end
  devise_for :users
  get '(/:sort)', to: 'tasks#index'
  root 'tasks#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

end
