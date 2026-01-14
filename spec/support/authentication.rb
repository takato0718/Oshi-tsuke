module AuthenticationHelper
  def login_as(user, password: 'password123')
    if respond_to?(:visit)
      # System specの場合
      visit new_session_path
      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: password
      click_button 'ログイン'
    else
      # Request specの場合
      # パスワードが設定されていない場合は設定
      if user.crypted_password.blank?
        user.password = password
        user.password_confirmation = password
        user.save!
      end

      # ログインリクエストを送信（selfはActionDispatch::Integration::Sessionのインスタンス）
      post session_path, params: { email: user.email, password: password }
      follow_redirect! if response.redirect?
    end
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
  config.include AuthenticationHelper, type: :system
end
