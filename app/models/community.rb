class Community < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  has_many :community_memberships, dependent: :destroy
  has_many :members, through: :community_memberships, source: :user
  has_many :posts, dependent: :destroy
  has_many :community_threads, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :creator_id, presence: true
  validates :is_public, inclusion: { in: [true, false] }

  scope :public_communities, -> { where(is_public: true) }
  scope :private_communities, -> { where(is_public: false) }
  scope :recent, -> { order(created_at: :desc) }

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
end
  