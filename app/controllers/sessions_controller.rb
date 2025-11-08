class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  
  def new
    redirect_to root_path if logged_in?
    @user = User.new
  end
  
  def create
    @user = login(params[:email], params[:password], params[:remember_me] == "1")
      
    if @user
      redirect_to root_path, notice: "ログインしました"
    else
      flash.now[:alert] = "メールアドレスまたはパスワードが正しくありません"
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    logout
    redirect_to root_path, notice: "ログアウトしました"
  end
end
