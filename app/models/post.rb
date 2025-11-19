require "uri"

class Post < ApplicationRecord
  belongs_to :user
  has_many :recommendations, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :youtube_url, format: { with: /\A(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/.+\z/i, message: "は有効なYouTube URLである必要があります" }, allow_blank: true
  validate :image_url_format

  scope :recent, -> { order(created_at: :desc) }
    
  def owned_by?(user)
    self.user == user
  end

  private

  def image_url_format
    return if image.blank?

    uri = begin
      URI.parse(image)
    rescue URI::InvalidURIError
      nil
    end

    unless uri&.is_a?(URI::HTTP) && uri.host.present?
      errors.add(:image, "は有効なURLを指定してください（例: https://example.com/image.jpg）")
      return
    end

    allowed_extensions = %w[jpg jpeg png gif webp]
    ext = File.extname(uri.path).delete(".").downcase
    unless allowed_extensions.include?(ext)
      errors.add(:image, "はjpg/jpeg/png/gif/webpのいずれかの拡張子を持つURLを指定してください")
    end
  end
end
