class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  # パスワードは、OAuth認証の場合は不要
  validates :password, length: { minimum: 6 }, if: :password_required?
  validates :password, confirmation: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

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

  # Google認証情報からユーザーを検索または作成
  def self.find_or_create_from_auth(auth)
    find_or_create_by(provider: auth['provider'], uid: auth['uid']) do |user|
      user.name = auth['info']['name']
      user.email = auth['info']['email']
      user.avatar_url = auth['info']['image']
    end
  end

  # プロフィール画像のURLを返す(優先順位: avatar_url > profile_image > デフォルト)
  def display_avatar
    avatar_url.presence || profile_image.presence || '/assets/default_avatar.png'
  end

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

  private

  # OAuth認証の場合はパスワードを不要にする
  def password_required?
    provider.blank? && (new_record? || crypted_password_changed?)
  end
end
