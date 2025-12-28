class Community < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  has_many :community_memberships, dependent: :destroy
  has_many :members, through: :community_memberships, source: :user

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
  
  # ユーザーがメンバーかどうか
  def member?(user)
    members.include?(user)
  end

  # ユーザーが管理者かどうか
  def admin?(user)
    community_memberships.exists?(user: user, role: :admin)
  end

  # ユーザーがモデレーターかどうか
  def moderator?(user)
    community_memberships.exists?(user: user, role: :moderator)
  end
end
  