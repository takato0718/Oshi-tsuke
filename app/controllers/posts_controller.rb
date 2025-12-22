class PostsController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :check_owner, only: [:edit, :update, :destroy]

  def index
    @categories = Category.ordered
    
    # Ransack検索の初期化
    @q = Post.includes(:user, :categories).ransack(params[:q])
    @posts = @q.result(distinct: true)
    
    # カテゴリー絞り込み（/posts?category[]=1&category[]=2 の形式で複数選択可能）
    category_ids = []
    
    # URLパラメータのcategory（カテゴリーナビゲーションから、配列形式）
    if params[:category].present?
      category_ids = Array(params[:category]).map(&:to_i).reject(&:zero?)
    end
    
    # カテゴリーで絞り込み
    if category_ids.any?
      @posts = @posts.joins(:categories).where(categories: { id: category_ids }).distinct
      @selected_category_ids = category_ids
    else
      @selected_category_ids = []
    end
    
    @posts = @posts.recent.page(params[:page]).per(20)
  end
  
  def show
    @post = Post.includes(:user, comments: :user).find(params[:id])
  end

  def new
    @post = current_user.posts.build
    @categories = Category.ordered
  end

  def create
    @post = current_user.posts.build(post_params)
    @categories = Category.ordered
      
    if @post.save
      redirect_to @post, notice: '推しを投稿しました！'
     else
      flash.now[:alert] = '投稿に失敗しました'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.ordered
  end
  
  def update
    @categories = Category.ordered
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
    params.require(:post).permit(:title, :description, :image, :youtube_url, category_ids: [])
  end
end
  