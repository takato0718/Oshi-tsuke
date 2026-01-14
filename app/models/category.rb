class Category < ApplicationRecord
  has_many :post_categories, dependent: :destroy
  has_many :posts, through: :post_categories

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }

  # Ransack の設定
  def self.ransackable_attributes(_auth_object = nil)
    %w[community_id created_at description id image title updated_at user_id youtube_url]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user categories post_categories]
  end
end
