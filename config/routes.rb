Rails.application.routes.draw do
  # トップページ
  root "home#index"

  get "signup", to: "registrations#new", as: :new_registration
  post "signup", to: "registrations#create", as: :registration
end
