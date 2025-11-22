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
    @user.recommendations.today.first
  end
  
  def find_recommendation_candidate
    excluded_post_ids = @user.recommendations.pluck(:post_id)
    candidate_posts = Post.where.not(id: excluded_post_ids)
                          .where.not(user_id: @user.id)
  
    candidate_posts.sample
  end
  
  def create_recommendation(post)
    @user.recommendations.create!(
      post: post,
      is_skipped: false
    )
  end
end
  