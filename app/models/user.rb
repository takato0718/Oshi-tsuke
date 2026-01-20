class User < ApplicationRecord
  authenticates_with_sorcery!

  # バリデーション
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  # パスワードは、OAuth認証の場合は不要
  validates :password, length: { minimum: 6 }, if: :password_required?
  validates :password, confirmation: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  # アソシエーション
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
    # providerとuidで既存ユーザーを検索
    user = find_by(provider: auth['provider'], uid: auth['uid'])
    return user if user

    # emailで既存ユーザーを検索してOAuth情報を追加
    user = find_by(email: auth['info']['email'])
    return link_oauth_account(user, auth) if user

    # 新規ユーザーを作成
    create_oauth_user(auth)
  rescue StandardError => e
    Rails.logger.error "OAuth認証エラー: #{e.class} - #{e.message}"
    nil
  end

  # プロフィール画像のURLを返す(優先順位: avatar_url > profile_image > デフォルト)
  def display_avatar
    avatar_url.presence || profile_image.presence || '/assets/default_avatar.png'
  end

  # OAuth認証ユーザーかどうかを判定
  def oauth_user?
    provider.present? && uid.present?
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
    # OAuth認証ユーザーでない かつ (新規作成 または パスワードが入力されている)
    !oauth_user? && (new_record? || password.present?)
  end

  # OAuth情報を既存ユーザーに追加
  def self.link_oauth_account(user, auth)
    user.update(
      provider: auth['provider'],
      uid: auth['uid'],
      avatar_url: auth['info']['image']
    )
    user
  end
  private_class_method :link_oauth_account

  # OAuth認証で新規ユーザーを作成
  def self.create_oauth_user(auth)
    create!(
      name: auth['info']['name'],
      email: auth['info']['email'],
      provider: auth['provider'],
      uid: auth['uid'],
      avatar_url: auth['info']['image']
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "OAuth認証ユーザー作成エラー: #{e.message}"
    nil
  end
  private_class_method :create_oauth_user
end
