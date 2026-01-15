class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  def new; end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    return if @user

    redirect_to new_session_path, alert: 'パスワードリセットのリンクが無効または期限切れです。'
    nil
  end

  def create
    @user = User.find_by(email: params[:email])

    if @user
      begin
        @user.deliver_reset_password_instructions!
        Rails.logger.info "✅ Password reset email sent to #{@user.email}"
      rescue Net::OpenTimeout => e
        Rails.logger.error "❌ SMTP timeout: #{e.message}"
        # タイムアウトしてもユーザーには成功メッセージを表示(セキュリティのため)
      rescue StandardError => e
        Rails.logger.error "❌ Failed to send email: #{e.class} - #{e.message}"
        # エラーが発生してもユーザーには成功メッセージを表示(セキュリティのため)
      end
    else
      Rails.logger.warn "⚠️ User not found for email: #{params[:email]}"
    end

    # セキュリティのため、存在しないメールアドレスでも同じメッセージを表示
    redirect_to new_session_path, notice: 'パスワードリセット用のメールを送信しました。メールをご確認ください。'
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    unless @user
      redirect_to new_session_path, alert: 'パスワードリセットのリンクが無効または期限切れです。'
      return
    end

    @user.password_confirmation = params[:user][:password_confirmation]

    if @user.change_password(params[:user][:password])
      redirect_to new_session_path, notice: 'パスワードを変更しました。新しいパスワードでログインしてください。'
    else
      flash.now[:alert] = 'パスワードの変更に失敗しました。'
      render :edit, status: :unprocessable_entity
    end
  end
end
