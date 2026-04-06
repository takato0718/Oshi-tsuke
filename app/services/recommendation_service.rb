class RecommendationService
  def initialize(user)
    @user = user
  end

  def generate_daily_recommendation
    existing_recommendation = find_today_recommendation
    return existing_recommendation if existing_recommendation

    candidate_post = find_recommendation_candidate
    return nil unless candidate_post

    create_recommendation(candidate_post)
  end

  private

  def find_today_recommendation
    @user.recommendations.includes(:post).today.first
  end

  def find_recommendation_candidate
    excluded_post_ids = @user.recommendations.pluck(:post_id)
    candidate_posts = Post.where.not(id: excluded_post_ids)
                          .where.not(user_id: @user.id)

    candidate_posts.sample
  end

  def create_recommendation(post)
    # UUIDがnilの場合は生成
    ensure_post_has_uuid(post)

    recommendation = @user.recommendations.create!(
      post: post,
      status: :pending
    )

    Recommendation.includes(:post).find(recommendation.id)
  end

  def ensure_post_has_uuid(post)
    return if post.uuid.present?

    new_uuid = SecureRandom.uuid
    post.update!(:uuid, new_uuid)
  end
end
