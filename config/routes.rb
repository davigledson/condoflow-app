Rails.application.routes.draw do
  root "tickets#index"

  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy",  as: :logout

  resources :users
  resources :blocks do
    resources :units, only: [] do
      member do
        post   :unit_residents, action: :create,  controller: "unit_residents"
        delete :unit_residents, action: :destroy, controller: "unit_residents"
      end
    end
  end

  resources :ticket_types
  resources :ticket_statuses
  resources :tickets, only: [:index, :show, :new, :create] do
    member do
      patch :update_status
    end
    resources :comments, only: [:create]
  end
end