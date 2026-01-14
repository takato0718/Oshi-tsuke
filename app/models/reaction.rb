class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :post

  enum :reaction_type, {
    like: 0,
    comment: 1
  }

  # rubocop:disable Rails/RedundantPresenceValidationOnBelongsTo
  validates :user_id, presence: true
  validates :post_id, presence: true
  # rubocop:enable Rails/RedundantPresenceValidationOnBelongsTo
  validates :reaction_type, presence: true
  validates :content, presence: true, if: :comment?
  validates :content, absence: true, if: :like?

  # ユニーク制約：いいねの場合だけ、同一ユーザーが同一投稿に複数回いいねできない
  validates :user_id, uniqueness: {
    scope: [:post_id],
    message: 'は既にこの投稿にいいねをしています',
    if: :like?
  }

  scope :likes, -> { where(reaction_type: :like) }
  scope :comments, -> { where(reaction_type: :comment) }
  scope :recent, -> { order(created_at: :desc) }

  # ユーザーがこのコメントを削除できるかどうか
  def can_be_deleted_by?(user)
    return false unless user
    return false unless comment? # いいねは削除できない

    owned_by?(user) # 通常の推し投稿のコメントは所有者のみ削除可能
  end

  # 所有者かどうか
  def owned_by?(user)
    self.user == user
  end
end
