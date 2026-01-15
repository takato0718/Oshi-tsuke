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

    # セキュリティのため、存在しないメールアドレスでも同じメッセージを表示
    @user&.deliver_reset_password_instructions!

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
