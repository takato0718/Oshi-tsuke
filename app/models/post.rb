require 'uri'

class Post < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  has_many :recommendations, dependent: :destroy
  has_many :post_categories, dependent: :destroy
  has_many :categories, through: :post_categories
  has_many :reactions, dependent: :destroy
  has_many :likes, -> { where(reaction_type: :like) }, class_name: 'Reaction'
  has_many :comments, -> { where(reaction_type: :comment) }, class_name: 'Reaction'

  # UUID自動生成（既存レコードにはマイグレーションで付与）
  before_validation :generate_uuid, on: :create

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :youtube_url,
            format: {
              with: %r{\A(https?://)?(www\.)?(youtube\.com|youtu\.be)/.+\z}i,
              message: 'は有効なYouTube URLである必要があります'
            },
            allow_blank: true
  validate :acceptable_image

  scope :recent, -> { order(created_at: :desc) }

  # Ransack で検索可能な属性を定義
  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at description id image title updated_at user_id youtube_url]
  end

  # Ransack で検索可能な関連を定義
  def self.ransackable_associations(_auth_object = nil)
    %w[user categories post_categories]
  end

  def owned_by?(user)
    self.user == user
  end

  # 指定されたユーザーがこの投稿にいいねしているかどうか
  def liked_by?(user)
    return false unless user

    likes.exists?(user: user)
  end

  # いいね数を取得
  delegate :count, to: :likes, prefix: true

  # URLでUUIDを使用
  def to_param
    uuid
  end

  private

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def acceptable_image
    return unless image.attached?

    unless image.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:image, 'はjpeg/png/gif/webpのいずれかの形式を指定してください')
    end

    if image.byte_size > 5.megabytes
      errors.add(:image, 'は5MB以下のファイルを指定してください')
    end
  end
end
