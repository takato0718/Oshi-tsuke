class Post < ApplicationRecord
  belongs_to :user
    
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :youtube_url, format: { with: /\A(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/.+\z/i, message: "は有効なYouTube URLである必要があります" }, allow_blank: true
    
  scope :recent, -> { order(created_at: :desc) }
    
  def owned_by?(user)
    self.user == user
  end
end
