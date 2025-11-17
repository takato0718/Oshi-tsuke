class PostsController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :check_owner, only: [:edit, :update, :destroy]

  def index
    @posts = Post.includes(:user).recent.page(params[:page]).per(20)
  end
  
  def show
    @post = Post.includes(:user).find(params[:id])
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
      
    if @post.save
      redirect_to @post, notice: '推しを投稿しました！'
     else
      flash.now[:alert] = '投稿に失敗しました'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end
  
  def update
    if @post.update(post_params)
      redirect_to @post, notice: '投稿を更新しました！'
    else
      flash.now[:alert] = '投稿の更新に失敗しました'
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @post.destroy
    redirect_to posts_url, notice: '投稿を削除しました。'
  end
  
  private
  
  def set_post
    @post = Post.find(params[:id])
  end
  
  def check_owner
    unless @post.owned_by?(current_user)
    redirect_to posts_path, alert: '権限がありません。'
    end
  end
  
  def post_params
    params.require(:post).permit(:title, :description, :image, :youtube_url)
  end
end
  