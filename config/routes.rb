Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get  "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  get  "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"
  resources :sessions, only: [ :index, :show, :destroy ]
  resource  :password, only: [ :edit, :update ]
  resources :users, excpet: [ :show ]
  get "users/cancel/:id", to: "users#cancel", as: "users_cancel"
  namespace :identity do
    resource :email,              only: [ :edit, :update ]
    resource :email_verification, only: [ :show, :create ]
    resource :password_reset,     only: [ :new, :edit, :create, :update ]
  end

  root "fdn/foundations#index"

  scope module: "fdn" do
    # charts
    get "foundation/:foundation_id/charts/top-donors", to: "charts#top_donors", as: "charts_top_donors"
    get "foundation/:foundation_id/charts/contribution-time-line", to: "charts#contribution_time_line", as: "charts_contribution_time_line"

    get "foundation/cancel", to: "foundations#cancel"
    resources :foundations, except: [ :show ] do
      get "dashboard", on: :member
      get "settings", on: :member
      delete "remove-image-logo", to: "foundations#remove_image_logo", as: "remove_image_logo"
      delete "remove-image-header", to: "foundations#remove_image_header", as: "remove_image_header"
      namespace "reporting" do
        get "dashboard", to: "reports#dashboard"
        get "organization_list", to: "reports#organization_list"
        get "commitment", to: "reports#get_commitment"
        get "contribution", to: "reports#get_contribution"
        post "commitment_report", to: "reports#show_commitment"
        post "contribution_report", to: "reports#show_contribution"
      end
      get "organizations/sort", to: "organizations#sort"
      resources :organizations do
        get "cancel", on: :member
        get "contributions", on: :member
        get "commitments", on: :member
      end
      scope module: "accounting" do
        resources :bank_accounts do
          get "cancel", on: :member
          resources :checks, shallow: true, except: [ :show ]
          get "reconciliations/cancel", to: "reconciliations#cancel"
          post "reconciliations/new_next", to: "reconciliations#new_next"
          resources :reconciliations, shallow: true, except: [ :edit, :update ]
        end
      end
      scope module: "donations" do
        get "contributions/new_next", to: "contributions#new_next"
        get "commitments/new_next", to: "commitments#new_next"
        get "contributions/sort", to: "contributions#sort"
        get "commitments/sort", to: "commitments#sort"
        resources :contributions do
          get "cancel", on: :member
        end
        resources :commitments do
          get "cancel", on: :member
          get "contribution/new", to: "commitments#new_contribution"
          post "contributions", to: "commitments#create_contribution"
          get "contribution/:id", to: "commitments#edit_contribution", as: "contribution"
          patch "contribution/:id", to: "commitments#update_contribution"
          delete "contribution/:id", to: "commitments#destroy_contribution"
        end
      end
      namespace :settings do
        resources :donors, except: [ :show ]
        resources :funding_sources, except: [ :show ]
        resources :organization_types, except: [ :show ]
      end
    end
  end
end
