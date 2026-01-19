class OauthSessionsController < ApplicationController
  skip_before_action :require_login, only: [:create]

  def create
    Rails.logger.info "=== OAuth認証開始 ==="
    user_info = request.env['omniauth.auth']
    Rails.logger.info "OAuth認証情報: #{user_info.inspect}"

    # ユーザーを検索または作成
    user = User.find_or_create_from_auth(user_info)
    Rails.logger.info "ユーザー作成結果: user=#{user.inspect}, persisted?=#{user&.persisted?}"


    if user&.persisted?
      # Sorceryのauto_loginメソッドでログイン
      auto_login(user)
      Rails.logger.info "OAuth認証成功: user_id=#{user.id}"
      redirect_to root_path, notice: 'Googleアカウントでログインしました'
    else
      Rails.logger.warn "OAuth認証失敗: ユーザー作成に失敗しました"
      Rails.logger.warn "ユーザーのエラー: #{user&.errors&.full_messages&.join(', ')}"

      redirect_to new_session_path, alert: 'ログインに失敗しました'
    end
  rescue StandardError => e
    Rails.logger.error "=== OAuth認証エラー ==="
    Rails.logger.error "エラークラス: #{e.class}"
    Rails.logger.error "エラーメッセージ: #{e.message}"
    Rails.logger.error "バックトレース:\n#{e.backtrace.join("\n")}"
    redirect_to new_session_path, alert: 'ログインに失敗しました'
  end
end
