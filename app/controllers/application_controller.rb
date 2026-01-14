class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { Rails.env.test? }
  before_action :require_login

  private

  def not_authenticated
    redirect_to new_session_path, alert: 'ログインが必要です'
  end
end
