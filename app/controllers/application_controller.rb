class ApplicationController < ActionController::Base
  before_action :require_login

  private
  def not_authenticated
    redirect_to new_user_session_path, alert: "ログインが必要です"
  end
end
