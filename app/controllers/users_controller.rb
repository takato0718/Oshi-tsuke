class UsersController < ApplicationController
  skip_before_action :require_login, only: [:show]
  before_action :set_user, only: %i[show recommendations]
  before_action :set_current_user, only: %i[edit update]
  before_action :check_recommendations_access, only: [:recommendations]

  def show; end

  def recommendations
    @recommendations = @user.recommendations
                            .includes(:post)
                            .order(created_at: :desc)
                            .page(params[:page])
                            .per(20)
  end

  def edit; end

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

  def check_recommendations_access
    # 自分の履歴のみ閲覧可能
    return if logged_in? && current_user == @user

    redirect_to user_path(@user), alert: '権限がありません'
  end

  def user_params
    params.require(:user).permit(:name, :email, :profile_image)
  end
end
