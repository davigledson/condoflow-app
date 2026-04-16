# config/routes.rb
Rails.application.routes.draw do
  root "tickets#index"

  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy",  as: :logout

  resources :users do
    member do
      post   :assign_ticket_type,   to: "collaborator_ticket_types#create"
      delete :unassign_ticket_type, to: "collaborator_ticket_types#destroy"
    end
  end

  namespace :admin do
  get "auditoria", to: "audits#index"
end

  
  resources :blocks do
    resources :units, only: [] do
      member do
        post   :link_resident,   to: "unit_residents#create"
        delete :unlink_resident, to: "unit_residents#destroy"
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