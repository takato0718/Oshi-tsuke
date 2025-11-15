class PostsController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :check_owner, only: [:edit, :update, :destroy]

  def index
  end
  
  def show
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
  end
  
  def destroy
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
  