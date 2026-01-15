class UserMailer < ApplicationMailer
  def reset_password_email(user)
    @user = user
    @token = user.reset_password_token
    @url = edit_password_reset_url(@token)

    mail(
      to: @user.email,
      subject: 'パスワードリセットのご案内'
    )
  end
end
