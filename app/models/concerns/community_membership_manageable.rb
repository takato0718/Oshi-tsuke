module CommunityMembershipManageable
  extend ActiveSupport::Concern

  # 公開・非公開判定
  def public?
    is_public
  end

  def private?
    !is_public
  end

  # ===== メンバーシップ判定メソッド =====

  # ユーザーがメンバーかどうか（承認済み）
  def member?(user)
    return false unless user

    community_memberships.exists?(user: user, is_active: true)
  end

  # ユーザーが承認待ちかどうか
  def pending_member?(user)
    return false unless user

    community_memberships.exists?(user: user, is_active: false)
  end

  # ユーザーが管理者かどうか
  def admin?(user)
    return false unless user

    community_memberships.exists?(user: user, role: :admin, is_active: true)
  end

  # ユーザーがモデレーターかどうか
  def moderator?(user)
    return false unless user

    community_memberships.exists?(user: user, role: :moderator, is_active: true)
  end

  # ユーザーが管理者またはモデレーターかどうか
  def moderator_or_admin?(user)
    return false unless user

    admin?(user) || moderator?(user)
  end

  # ユーザーが投稿・コメントを削除できるかどうか
  def can_moderate?(user)
    return false unless user

    admin?(user) || moderator?(user) || creator == user
  end

  # ===== メンバー取得メソッド =====

  # ユーザーのメンバーシップを取得
  def membership_for(user)
    return nil unless user

    community_memberships.find_by(user: user)
  end

  # 承認待ちメンバーを取得
  def pending_members
    User.joins(:community_memberships)
        .where(community_memberships: { community_id: id, is_active: false })
  end

  # アクティブメンバーを取得
  def active_members
    User.joins(:community_memberships)
        .where(community_memberships: { community_id: id, is_active: true })
  end
end
