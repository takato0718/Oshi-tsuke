class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  has_many :posts, dependent: :destroy
  has_many :community_threads, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :recommendations, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :likes, -> { where(reaction_type: :like) }, class_name: 'Reaction'
  has_many :comments, -> { where(reaction_type: :comment) }, class_name: 'Reaction'
  has_many :created_communities, class_name: 'Community', foreign_key: 'creator_id', dependent: :destroy
  has_many :community_memberships, dependent: :destroy
  has_many :communities, through: :community_memberships
  has_many :reports, dependent: :destroy
  has_many :reviewed_reports, class_name: 'Report', foreign_key: 'reviewed_by_id', dependent: :nullify

  # モデレーター権限のあるコミュニティIDを取得
  def moderatable_community_ids
    communities.joins(:community_memberships)
               .where(community_memberships: {
                        user_id: id,
                        role: %i[moderator admin],
                        is_active: true
                      })
               .pluck(:id)
  end
end
