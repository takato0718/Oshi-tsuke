Rails.application.routes.draw do
  # トップページ
  root "home#index"

  get "login", to: "sessions#new", as: :new_session
  post "login", to: "sessions#create", as: :session
  delete "logout", to: "sessions#destroy", as: :logout
  get "signup", to: "registrations#new", as: :new_registration
  post "signup", to: "registrations#create", as: :registration
end
