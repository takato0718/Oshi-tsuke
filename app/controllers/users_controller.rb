class UsersController < ApplicationController
  skip_before_action :require_login, only: [:show]
  before_action :set_user, only: [:show]
  before_action :set_current_user, only: [:edit, :update]
  
  def show
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'プロフィールを更新しました'
    else
      flash.now[:alert] = 'プロフィールの更新に失敗しました'
      render :edit, status: :unprocessable_entity
    end
  end
  
  # /profile へのショートカット
  def me
    return redirect_to new_session_path, alert: 'ログインが必要です' unless logged_in?
    redirect_to user_path(current_user)
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def set_current_user
    @user = current_user
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :profile_image)
  end
end
  