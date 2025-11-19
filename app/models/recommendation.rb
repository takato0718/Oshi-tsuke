class Recommendation < ApplicationRecord
  belongs_to :user
  belongs_to :post
  
  validates :user_id, presence: true
  validates :post_id, presence: true
  validates :is_skipped, inclusion: { in: [true, false] }
  
  scope :today, -> { where(created_at: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :skipped, -> { where(is_skipped: true) }
  scope :not_skipped, -> { where(is_skipped: false) }
  
  def skip!
    update!(is_skipped: true, skipped_at: Time.current, viewed_at: Time.current)
  end

  def mark_as_viewed!
    update!(viewed_at: Time.current) unless viewed_at.present?
  end
end