class CommunitiesController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]
  before_action :set_community, only: [:show, :join, :leave]
  before_action :check_membership_for_show, only: [:show]
  
  def index
    @communities = Community.includes(:creator, :members)
                            .recent
                            .page(params[:page])
                            .per(20)
  end
  
  def show
    @is_member = logged_in? && @community.member?(current_user)
    @is_pending = logged_in? && @community.pending_member?(current_user)
    @can_moderate = logged_in? && @community.can_moderate?(current_user)
    @is_admin = logged_in? && @community.admin?(current_user)
    
    # メンバーの場合のみスレッドを取得
    if @is_member
      @threads = @community.community_threads
                           .includes(:user, :replies, replies: :user)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(20)
    end
    
    # 管理者・モデレーターの場合、承認待ちメンバーを取得
    if @is_admin || @can_moderate
      @pending_memberships = @community.community_memberships.pending.includes(:user)
    end
  end
  
  def new
    @community = current_user.created_communities.build
  end
  
  def create
    @community = current_user.created_communities.build(community_params)
  
    if @community.save
      # 作成者を自動的に管理者として追加,常にis_active: trueの状態
      @community.community_memberships.create!(
        user: current_user,
        role: :admin,
        is_active: true,
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

    # 既に参加しているか承認待ちかチェック
    existing_membership = @community.community_memberships.find_by(user: current_user)
  
    if existing_membership
      if existing_membership.is_active?
        redirect_to @community, alert: '既に参加しています'
      else
        redirect_to @community, alert: '既に参加申請中です。承認をお待ちください'
      end
      return
    end
  
    # 公開コミュニティ: 即参加（is_active: true）
    # 非公開コミュニティ: 承認待ち（is_active: false）
    is_active = @community.public?

    membership = @community.community_memberships.create!(
      user: current_user,
      role: :member,
      is_active: is_active,
      joined_at: is_active ? Time.current : nil # 承認待ちの場合はjoined_atはnil
    )
  
    if is_active
      redirect_to @community, notice: 'コミュニティに参加しました！'
    else
      redirect_to @community, notice: '参加申請を送信しました。承認をお待ちください'
    end
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
    # 公開コミュニティは誰でも閲覧可能
    # 非公開コミュニティも詳細ページは閲覧可能（ただし投稿はメンバーのみ）
    # このメソッドは常に通過（詳細ページの閲覧は制限しない）
  end

  def community_params
    params.require(:community).permit(:name, :description, :is_public)
  end
end
