class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :community_thread
  has_many :reports, as: :reportable, dependent: :destroy

  validates :description, presence: true

  scope :recent, -> { order(created_at: :asc) } # 古いものが上（コミュニティスレッド用）

  # ユーザーがこのレスを削除できるかどうか
  def can_be_deleted_by?(user)
    return false unless user

    owned_by?(user) || community_thread.community.can_moderate?(user)
  end

  # 所有者かどうか
  def owned_by?(user)
    self.user == user
  end

  # コミュニティを取得
  delegate :community, to: :community_thread
end
