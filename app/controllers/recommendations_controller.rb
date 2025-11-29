class RecommendationsController < ApplicationController
  before_action :set_recommendation, only: [:show, :skip, :like]
  
  def daily
    service = RecommendationService.new(current_user)
    @recommendation = service.generate_daily_recommendation
    
    if @recommendation.nil?
      redirect_to posts_path, notice: '今日の推し紹介はありません。他の投稿を見てみましょう！'
      return
    end
  
    @post = @recommendation.post
    @recommendation.mark_as_viewed!
  end
  
  def show
    @post = @recommendation.post
    @recommendation.mark_as_viewed!
  end
  
  def skip
    @recommendation.skip!
  
    respond_to do |format|
      format.json { render json: { status: 'success', message: 'スキップしました' } }
      format.html { redirect_to posts_path, notice: 'スキップしました' }
    end
  end
  
  def like
    @recommendation.update!(is_skipped: false, viewed_at: Time.current)
  
    respond_to do |format|
      format.json { render json: { status: 'success', message: '興味ありに登録しました' } }
      format.html { redirect_to post_path(@recommendation.post), notice: '興味ありに登録しました！投稿詳細を見てみましょう' }
    end
  end
  
  private
  
  def set_recommendation
    @recommendation = current_user.recommendations.find(params[:id])
  end
end
