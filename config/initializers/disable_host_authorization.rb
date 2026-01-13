# テスト環境ではHost Authorizationミドルウェアを削除
if Rails.env.test?
  Rails.application.config.middleware.delete ActionDispatch::HostAuthorization
end
  