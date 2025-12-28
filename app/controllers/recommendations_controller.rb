class RecommendationsController < ApplicationController
  before_action :set_recommendation, only: [:show, :skip, :favorite]
  
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
  
  # スキップ処理（Ajax対応）
  def skip
    # 状態チェック: pendingでない場合はエラー
    unless @recommendation.pending?
      respond_to do |format|
        format.json { render json: { status: 'error', message: '既に選択済みです' }, status: :unprocessable_entity }
        format.html { redirect_to daily_recommendations_path, alert: '既に選択済みです' }
      end
      return
    end

    @recommendation.skip!

    respond_to do |format|
      format.json { 
        render json: { 
          status: 'success', 
          message: 'スキップしました',
          recommendation_status: @recommendation.status,
          recommendation_id: @recommendation.id
        } 
      }
      format.html { redirect_to daily_recommendations_path, notice: 'スキップしました' }
    end
  end
  
  # お気に入り処理（Ajax対応）
  def favorite
    # 状態チェック: pendingでない場合はエラー
    unless @recommendation.pending?
      respond_to do |format|
        format.json { render json: { status: 'error', message: '既に選択済みです' }, status: :unprocessable_entity }
        format.html { redirect_to daily_recommendations_path, alert: '既に選択済みです' }
      end
      return
    end

    @recommendation.favorite!

    respond_to do |format|
      format.json { 
        render json: { 
          status: 'success', 
          message: '✨ この推しをお気に入りに追加しました!',
          recommendation_status: @recommendation.status,
          recommendation_id: @recommendation.id
        } 
      }
      format.html { redirect_to post_path(@recommendation.post), notice: '✨ この推しをお気に入りに追加しました!' }
    end
  end
  
  private
  
  def set_recommendation
    @recommendation = current_user.recommendations.find(params[:id])
  end
end
