class Recommendation < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # rubocop:disable Rails/RedundantPresenceValidationOnBelongsTo
  validates :user_id, presence: true
  validates :post_id, presence: true
  # rubocop:enable Rails/RedundantPresenceValidationOnBelongsTo

  # 状態管理: enumでstatusを定義
  enum :status, {
    pending: 0, # 未選択
    favorited: 1, # お気に入り済み
    skipped: 2    # スキップ済み
  }

  scope :today, -> { where(created_at: Date.current.all_day) }
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
    update!(viewed_at: Time.current) if viewed_at.blank?
  end
end
