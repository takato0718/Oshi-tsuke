class CommunityThread < ApplicationRecord
  belongs_to :user
  belongs_to :community
  has_many :replies, dependent: :destroy
    
  validates :description, presence: true
    
  scope :recent, -> { order(created_at: :desc) } # 新しいスレッドが下に来るように降順
  scope :oldest_first, -> { order(created_at: :asc) } # 古いものが上（コミュニティスレッド用）
    
  # レス数を取得
  def replies_count
    replies.count
  end
end