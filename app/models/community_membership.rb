class CommunityMembership < ApplicationRecord
  belongs_to :user
  belongs_to :community
  
  # 権限レベルのenum定義
  enum role: {
    member: 0,      # 一般メンバー
    moderator: 1,   # モデレーター
    admin: 2        # 管理者
  }
  
  validates :user_id, presence: true
  validates :community_id, presence: true
  validates :role, presence: true
  
  # ユニーク制約：同一ユーザーが同一コミュニティに重複参加できない
  validates :user_id, uniqueness: { 
    scope: :community_id, 
    message: "は既にこのコミュニティに参加しています" 
  }
  
  # 参加日時を自動設定
  before_create :set_joined_at
  
  scope :admins, -> { where(role: :admin) }
  scope :moderators, -> { where(role: :moderator) }
  scope :members, -> { where(role: :member) }
  scope :recent, -> { order(joined_at: :desc) }
  
  private
  
  def set_joined_at
    self.joined_at ||= Time.current
  end
end
  