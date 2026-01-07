class Community < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  has_many :community_memberships, dependent: :destroy
  has_many :members, through: :community_memberships, source: :user
  has_many :posts, dependent: :destroy
  has_many :community_threads, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :replies, through: :community_threads, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :creator_id, presence: true
  validates :is_public, inclusion: { in: [true, false] }

  scope :public_communities, -> { where(is_public: true) }
  scope :private_communities, -> { where(is_public: false) }
  scope :recent, -> { order(created_at: :desc) }

  # 活発度ランキング用スコープ
  scope :by_activity, -> {
    left_joins(community_threads: :replies)
      .group('communities.id')
      .select(
        'communities.id',
        'communities.name',
        'communities.description',
        'communities.is_public',
        'communities.creator_id',
        'communities.created_at',
        'communities.updated_at',
        'COALESCE(COUNT(DISTINCT community_threads.id), 0) * 2 + 
         COALESCE(COUNT(DISTINCT replies.id), 0) AS activity_score'
      )
      .order('activity_score DESC')
  }

  scope :by_thread_count, -> { 
    left_joins(:community_threads)
      .group('communities.id')
      .select(
        'communities.id',
        'communities.name',
        'communities.description',
        'communities.is_public',
        'communities.creator_id',
        'communities.created_at',
        'communities.updated_at',
        'COUNT(DISTINCT community_threads.id) AS threads_count'
      )
      .order('threads_count DESC')
  }

  scope :by_reply_count, -> { 
    left_joins(community_threads: :replies)
      .group('communities.id')
      .select(
        'communities.id',
        'communities.name',
        'communities.description',
        'communities.is_public',
        'communities.creator_id',
        'communities.created_at',
        'communities.updated_at',
        'COUNT(DISTINCT replies.id) AS replies_count'
      )
      .order('replies_count DESC')
  }

  scope :by_member_count, -> { 
    left_joins(:community_memberships)
      .where(community_memberships: { is_active: true })
      .group('communities.id')
      .select(
        'communities.id',
        'communities.name',
        'communities.description',
        'communities.is_public',
        'communities.creator_id',
        'communities.created_at',
        'communities.updated_at',
        'COUNT(DISTINCT community_memberships.user_id) AS members_count'
      )
      .order('members_count DESC')
  }

  def public?
    is_public
  end

  def private?
    !is_public
  end

  # ユーザーがメンバーかどうか（承認済み）
  def member?(user)
    return false unless user
    community_memberships.exists?(user: user, is_active: true)
  end

  # ユーザーが承認待ちかどうか
  def pending_member?(user)
    return false unless user
    community_memberships.exists?(user: user, is_active: false)
  end

  # ユーザーが管理者かどうか
  def admin?(user)
    return false unless user
    community_memberships.exists?(user: user, role: :admin, is_active: true)
  end

  # ユーザーがモデレーターかどうか
  def moderator?(user)
    return false unless user
    community_memberships.exists?(user: user, role: :moderator, is_active: true)
  end

  # ユーザーが管理者またはモデレーターかどうか
  def moderator_or_admin?(user)
    return false unless user
    admin?(user) || moderator?(user)
  end

  # ユーザーが投稿・コメントを削除できるかどうか
  def can_moderate?(user)
    return false unless user
    admin?(user) || moderator?(user) || creator == user
  end

  # ユーザーのメンバーシップを取得
  def membership_for(user)
    return nil unless user
    community_memberships.find_by(user: user)
  end

  # 承認待ちメンバーを取得
  def pending_members
    User.joins(:community_memberships)
        .where(community_memberships: { community_id: id, is_active: false })
  end

  # アクティブメンバーを取得
  def active_members
    User.joins(:community_memberships)
        .where(community_memberships: { community_id: id, is_active: true })
  end

  # ===== 統計・活発度関連メソッド =====
  
  # スレッド数を取得
  def threads_count
    community_threads.count
  end
  
  # レス数を取得
  def replies_count
    replies.count
  end
  
  # 総投稿数（スレッド + レス）を取得
  def total_posts_count
    threads_count + replies_count
  end
  
  # メンバー数を取得（承認済みのみ）
  def members_count
    active_members.count
  end
  
  # 活発度スコアを計算（投稿数 + レス数）
  def activity_score
    # スレッド数 * 2 + レス数
    threads_count * 2 + replies_count
  end
  
  # 最近の活動度（過去7日間の投稿数）
  def recent_activity_count(days: 7)
    since = days.days.ago
    threads = community_threads.where('created_at >= ?', since).count
    replies_count = replies.where('created_at >= ?', since).count
    threads + replies_count
  end
  
  # 活発度バッジ用のレベル判定
  def activity_level
    score = activity_score
    case score
    when 0..10
      'low'
    when 11..50
      'medium'
    when 51..200
      'high'
    else
      'very_high'
    end
  end
end
  