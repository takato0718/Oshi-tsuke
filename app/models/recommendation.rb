class Recommendation < ApplicationRecord
  belongs_to :user
  belongs_to :post
  
  validates :user_id, presence: true
  validates :post_id, presence: true
  
  # 状態管理: enumでstatusを定義
  enum status: {
    pending: 0,    # 未選択
    favorited: 1, # お気に入り済み
    skipped: 2    # スキップ済み
  }
  
  scope :today, -> { where(created_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :skipped, -> { where(status: :skipped) }
  scope :not_skipped, -> { where(status: :favorited) }
  scope :pending, -> { where(status: :pending) }
  
  def skip!
    update!(status: :skipped, skipped_at: Time.current, viewed_at: Time.current)
  end

  def favorite!
    update!(status: :favorited, viewed_at: Time.current)
  end

  def mark_as_viewed!
    update!(viewed_at: Time.current) unless viewed_at.present?
  end
end