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
  resources :users, only: [:show, :edit, :update] do
    member do
      get :recommendations
    end
  end
  get 'profile', to: 'users#me', as: :profile

  # 投稿
  resources :posts do
    resources :reactions, only: [:create] do
      collection do
        delete :destroy
      end
    end
    resources :comments, only: [:create, :destroy], controller: 'comments'
  end

  # 推し紹介
  resources :recommendations, only: [:show] do
    member do
      patch :skip
      patch :favorite
    end
    collection do
      get :daily
    end
  end
  
  # コミュニティスレッド
  resources :community_threads, only: [] do
    resources :replies, only: [:create], controller: 'replies' # レス投稿用
  end

  # コミュニティ
  resources :communities, only: [:index, :show, :new, :create] do
    collection do
      get :ranking
    end
    member do
      post :join
      delete :leave
    end
    resources :threads, only: [:create], controller: 'threads' # スレッド作成用

    # コミュニティ管理機能（モデレーター・管理者用）
    resources :moderations, only: [], controller: 'community_moderations', param: :id do
      member do
        patch :approve_membership
        patch :change_role
      end
      collection do
        delete :destroy_thread
        delete :destroy_reply
      end
    end
  end

  # 報告機能
  resources :reports, only: [:index, :show, :create] do
    member do
      patch :review
      patch :dismiss
    end
  end
end
