class OauthSessionsController < ApplicationController
  skip_before_action :require_login, only: [:create]

  def create
    user_info = request.env['omniauth.auth']

    # ユーザーを検索または作成
    user = User.find_or_create_from_auth(user_info)

    if user&.persisted?
      # Sorceryのauto_loginメソッドでログイン
      auto_login(user)
      redirect_to root_path, notice: 'Googleアカウントでログインしました'
    else
      redirect_to new_session_path, alert: 'ログインに失敗しました'
    end
  rescue StandardError => e
    Rails.logger.error "OAuth認証エラー: #{e.message}"
    redirect_to new_session_path, alert: 'ログインに失敗しました'
  end
end
