class ReactionsController < ApplicationController
  before_action :set_post
  before_action :set_reaction, only: [:destroy]

  # POST /posts/:post_id/reactions
  def create
    @reaction = @post.reactions.build(
      user: current_user,
      reaction_type: :like
    )

    respond_to do |format|
      if @reaction.save
        format.json do
          render json: {
            status: 'success',
            message: 'いいねしました',
            likes_count: @post.likes.count,
            liked: true
          }
        end
        format.html { redirect_to @post, notice: 'いいねしました' }
      else
        format.json do
          render json: {
            status: 'error',
            message: @reaction.errors.full_messages.join(', ')
          }, status: :unprocessable_entity
        end
        format.html { redirect_to @post, alert: 'いいねに失敗しました' }
      end
    end
  end

  # DELETE /posts/:post_id/reactions
  def destroy
    respond_to do |format|
      if @reaction&.destroy
        format.json do
          render json: {
            status: 'success',
            message: 'いいねを解除しました',
            likes_count: @post.likes.count,
            liked: false
          }
        end
        format.html { redirect_to @post, notice: 'いいねを解除しました' }
      else
        format.json do
          render json: {
            status: 'error',
            message: 'いいねの解除に失敗しました'
          }, status: :unprocessable_entity
        end
        format.html { redirect_to @post, alert: 'いいねの解除に失敗しました' }
      end
    end
  end

  private

  def set_post
    @post = Post.find_by!(uuid: params[:post_id])
  end

  def set_reaction
    @reaction = @post.reactions.likes.find_by(user: current_user)
    return if @reaction

    respond_to do |format|
      format.json do
        render json: {
          status: 'error',
          message: 'いいねが見つかりませんでした'
        }, status: :not_found
      end
      format.html { redirect_to @post, alert: 'いいねが見つかりませんでした' }
    end
  end
end
