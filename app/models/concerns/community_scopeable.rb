module CommunityScopeable
  extend ActiveSupport::Concern

  included do
    scope :public_communities, -> { where(is_public: true) }
    scope :private_communities, -> { where(is_public: false) }
    scope :recent, -> { order(created_at: :desc) }

    # 活発度ランキング用スコープ
    scope :by_activity, lambda {
      left_joins(community_threads: :replies)
        .group('communities.id')
        .select(
          'communities.id',
          'communities.uuid',
          'communities.name',
          'communities.description',
          'communities.is_public',
          'communities.creator_id',
          'communities.created_at',
          'communities.updated_at',
          'COALESCE(COUNT(DISTINCT community_threads.id), 0) * 2 +
               COALESCE(COUNT(DISTINCT replies.id), 0) AS activity_score'
        )
        .order(activity_score: :desc)
    }

    scope :by_thread_count, lambda {
      left_joins(:community_threads)
        .group('communities.id')
        .select(
          'communities.id',
          'communities.uuid',
          'communities.name',
          'communities.description',
          'communities.is_public',
          'communities.creator_id',
          'communities.created_at',
          'communities.updated_at',
          'COUNT(DISTINCT community_threads.id) AS threads_count'
        )
        .order(threads_count: :desc)
    }

    scope :by_reply_count, lambda {
      left_joins(community_threads: :replies)
        .group('communities.id')
        .select(
          'communities.id',
          'communities.uuid',
          'communities.name',
          'communities.description',
          'communities.is_public',
          'communities.creator_id',
          'communities.created_at',
          'communities.updated_at',
          'COUNT(DISTINCT replies.id) AS replies_count'
        )
        .order(replies_count: :desc)
    }

    scope :by_member_count, lambda {
      left_joins(:community_memberships)
        .where(community_memberships: { is_active: true })
        .group('communities.id')
        .select(
          'communities.id',
          'communities.uuid',
          'communities.name',
          'communities.description',
          'communities.is_public',
          'communities.creator_id',
          'communities.created_at',
          'communities.updated_at',
          'COUNT(DISTINCT community_memberships.user_id) AS members_count'
        )
        .order(members_count: :desc)
    }
  end
end
