class Reply < ApplicationRecord
  belongs_to :user
  belongs_to :community_thread
    
  validates :description, presence: true
    
  scope :recent, -> { order(created_at: :asc) } # 古いものが上（コミュニティスレッド用）
end
