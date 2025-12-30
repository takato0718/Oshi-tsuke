class CommunitiesController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]
  before_action :set_community, only: [:show, :join, :leave]
  before_action :check_membership_for_show, only: [:show]
  
  def index
    @communities = Community.includes(:creator, :members)
                            .public_communities
                            .recent
                            .page(params[:page])
                            .per(20)
  end
  
  def show
    # スレッドの親投稿のみを取得
    @threads = @community.community_threads
                         .includes(:user, :replies, replies: :user)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(20)
    @is_member = logged_in? && @community.member?(current_user)
  end
  
  def new
    @community = current_user.created_communities.build
  end
  
  def create
    @community = current_user.created_communities.build(community_params)
  
    if @community.save
      # 作成者を自動的に管理者として追加
      @community.community_memberships.create!(
        user: current_user,
        role: :admin,
        joined_at: Time.current
      )
      redirect_to @community, notice: 'コミュニティを作成しました！'
    else
      flash.now[:alert] = 'コミュニティの作成に失敗しました'
      render :new, status: :unprocessable_entity
    end
  end
  
  # コミュニティに参加
  def join
    unless logged_in?
      redirect_to new_session_path, alert: 'ログインが必要です'
      return
    end
  
    if @community.member?(current_user)
      redirect_to @community, alert: '既に参加しています'
      return
    end
  
    @community.community_memberships.create!(
      user: current_user,
      role: :member,
      joined_at: Time.current
    )
  
    redirect_to @community, notice: 'コミュニティに参加しました！'
  end
  
  # コミュニティから脱退
  def leave
    unless logged_in?
      redirect_to new_session_path, alert: 'ログインが必要です'
      return
    end
  
    membership = @community.community_memberships.find_by(user: current_user)
      
    if membership.nil?
      redirect_to @community, alert: '参加していません'
      return
    end
  
    # 作成者は脱退できない
    if @community.creator == current_user
      redirect_to @community, alert: 'コミュニティ作成者は脱退できません'
      return
    end
  
    membership.destroy
    redirect_to communities_path, notice: 'コミュニティから脱退しました'
  end

  private

  def set_community
    @community = Community.find(params[:id])
  end

  def check_membership_for_show
    # 公開コミュニティまたはメンバーの場合のみ閲覧可能
    return if @community.public?
    return if logged_in? && @community.member?(current_user)

    redirect_to communities_path, alert: 'このコミュニティはメンバー限定です'
  end

  def community_params
    params.require(:community).permit(:name, :description, :is_public)
  end
end
