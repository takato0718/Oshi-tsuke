class RecommendationsController < ApplicationController
  before_action :set_recommendation, only: %i[skip favorite]
  before_action :set_post, only: %i[skip favorite]

  def daily
    service = RecommendationService.new(current_user)
    @recommendation = service.generate_daily_recommendation

    if @recommendation.nil?
      redirect_to posts_path, notice: '今日の推し紹介はありません。他の投稿を見てみましょう!'
      return
    end

    @post = @recommendation.post
    @recommendation.mark_as_viewed!
  end

  # スキップ処理（Turbo Streams対応）
  def skip
    return render_already_selected_error unless @recommendation.pending?

    @recommendation.skip!
    render_skip_response
  end

  # お気に入り処理（Turbo Streams対応）
  def favorite
    return render_already_selected_error unless @recommendation.pending?

    @recommendation.favorite!
    render_favorite_response
  end

  private

  def set_recommendation
    @recommendation = current_user.recommendations.find(params[:id])
  end

  def set_post
    @post = @recommendation.post
  end

  # 既に選択済みの場合のエラーレスポンス
  def render_already_selected_error
    respond_to do |format|
      format.turbo_stream do
        flash.now[:alert] = '既に選択済みです'
        render turbo_stream: turbo_stream.replace(
          'selection-area',
          partial: 'recommendations/selection_buttons',
          locals: { recommendation: @recommendation, post: @post }
        )
      end
      format.json do
        render json: { status: 'error', message: '既に選択済みです' },
               status: :unprocessable_entity
      end
      format.html do
        flash.now[:alert] = '既に選択済みです'
        render :daily
      end
    end
  end

  # スキップ成功時のレスポンス
  def render_skip_response
    respond_to do |format|
      format.turbo_stream
      format.json do
        render json: {
          status: 'success',
          message: 'スキップしました',
          recommendation_status: @recommendation.status,
          recommendation_id: @recommendation.id,
          post_uuid: @post&.uuid
        }
      end
      format.html do
        flash.now[:notice] = 'スキップしました'
        render :daily
      end
    end
  end

  # お気に入り成功時のレスポンス
  def render_favorite_response
    respond_to do |format|
      format.turbo_stream
      format.json do
        render json: {
          status: 'success',
          message: '✨ この推しをお気に入りに追加しました!',
          recommendation_status: @recommendation.status,
          recommendation_id: @recommendation.id,
          post_uuid: @post&.uuid
        }
      end
      format.html do
        flash.now[:notice] = '✨ この推しをお気に入りに追加しました!'
        render :daily
      end
    end
  end
end
