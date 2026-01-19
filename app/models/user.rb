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
    Rails.logger.info '=== find_or_create_from_auth 開始 ==='
    Rails.logger.info "auth情報: provider=#{auth['provider']}, uid=#{auth['uid']}, email=#{auth['info']['email']}"

    # providerとuidで既存ユーザーを検索
    user = find_by(provider: auth['provider'], uid: auth['uid'])
    Rails.logger.info "providerとuidでの検索結果: #{user.inspect}"

    if user
      # 既存ユーザーが見つかった場合
      Rails.logger.info "既存ユーザーが見つかりました: user_id=#{user.id}"
      return user
    end

    # 既存ユーザーが見つからない場合、emailで検索
    user = find_by(email: auth['info']['email'])
    Rails.logger.info "emailでの検索結果: #{user.inspect}"

    if user
      # emailが一致するユーザーが見つかった場合、OAuth情報を追加
      Rails.logger.info "emailが一致するユーザーが見つかりました: user_id=#{user.id}"
      Rails.logger.info "OAuth情報を追加します: provider=#{auth['provider']}, uid=#{auth['uid']}"

      user.update_columns(
        provider: auth['provider'],
        uid: auth['uid'],
        avatar_url: auth['info']['image']
      )

      Rails.logger.info 'OAuth情報を追加しました'
      return user
    end

    # 新規ユーザーを作成
    Rails.logger.info '新規ユーザーを作成します'
    user = new(
      name: auth['info']['name'],
      email: auth['info']['email'],
      provider: auth['provider'],
      uid: auth['uid'],
      avatar_url: auth['info']['image']
    )

    # OAuth認証の場合はバリデーションをスキップして保存
    user.save(validate: false)
    Rails.logger.info "新規ユーザー作成結果: user_id=#{user.id}, persisted?=#{user.persisted?}"

    if user.persisted?
      Rails.logger.info '新規ユーザー作成成功'
    else
      Rails.logger.error "新規ユーザー作成失敗: #{user.errors.full_messages.join(', ')}"
    end

    user
  rescue StandardError => e
    Rails.logger.error '=== find_or_create_from_auth エラー ==='
    Rails.logger.error "エラークラス: #{e.class}"
    Rails.logger.error "エラーメッセージ: #{e.message}"
    Rails.logger.error "バックトレース:\n#{e.backtrace.join("\n")}"
    nil
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
