module LoginHelper
  def login_as(user)
    post session_path, params: {
      email: user.email,
      password: 'password123'
    }
  end
end

RSpec.configure do |config|
  config.include LoginHelper, type: :request
end
