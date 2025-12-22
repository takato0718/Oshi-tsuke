class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :post

  enum reaction_type: {
    like: 0,
    comment: 1
  }

  validates :user_id, presence: true
  validates :post_id, presence: true
  validates :reaction_type, presence: true
  validates :content, presence: true, if: :comment?
  validates :content, absence: true, if: :like?
  
  # ユニーク制約：いいねの場合だけ、同一ユーザーが同一投稿に複数回いいねできない
  validates :user_id, uniqueness: { 
    scope: [:post_id], 
    message: "は既にこの投稿にいいねをしています",
    if: :like?
  }

  scope :likes, -> { where(reaction_type: :like) }
  scope :comments, -> { where(reaction_type: :comment) }
  scope :recent, -> { order(created_at: :desc) }
end