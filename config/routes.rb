Rails.application.routes.draw do
  # トップページ
  root "home#index"
  # 認証
  get "login", to: "sessions#new", as: :new_session
  post "login", to: "sessions#create", as: :session
  delete "logout", to: "sessions#destroy", as: :logout
  get "signup", to: "registrations#new", as: :new_registration
  post "signup", to: "registrations#create", as: :registration

  # ユーザー
  resources :users, only: [:show, :edit, :update]
  get 'profile', to: 'users#me', as: :profile

  # 投稿
  resources :posts do
    resources :reactions, only: [:create] do
      collection do
        delete :destroy
      end
    end
  end

  # 推し紹介
  resources :recommendations, only: [:show] do
    member do
      patch :skip
      patch :like
    end
    collection do
      get :daily
    end
  end
end
