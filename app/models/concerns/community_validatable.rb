module CommunityValidatable
  extend ActiveSupport::Concern

  included do
    # UUID自動生成
    before_validation :generate_uuid, on: :create

    validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
    validates :description, length: { maximum: 1000 }, allow_blank: true
    validates :creator_id, presence: true
    validates :is_public, inclusion: { in: [true, false] }
  end

  # URLでUUIDを使用
  def to_param
    uuid
  end

  private

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
