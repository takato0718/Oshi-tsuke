class RepliesController < ApplicationController
  before_action :set_community_thread
  before_action :check_community_member, only: [:create]
  before_action :set_reply, only: [:destroy]
  before_action :check_reply_owner, only: [:destroy]

  # POST /community_threads/:community_thread_id/replies
  def create
    @reply = current_user.replies.build(
      description: reply_params[:description],
      community_thread_id: @community_thread.id
    )

    if @reply.save
      redirect_to @community_thread.community, notice: 'レスを投稿しました！'
    else
      error_messages = @reply.errors.full_messages.join(', ')
      redirect_to @community_thread.community, alert: "レス投稿に失敗しました: #{error_messages}"
    end
  end

  def destroy
    @reply.destroy
    redirect_to @community_thread.community, notice: 'レスを削除しました'
  end

  private

  def set_community_thread
    @community_thread = CommunityThread.find(params[:community_thread_id])
  end

  def set_reply
    @reply = @community_thread.replies.find(params[:id])
  end

  def check_community_member
    return if @community_thread.community.member?(current_user)

    redirect_to @community_thread.community, alert: 'このコミュニティのメンバーのみ投稿できます'
  end

  def check_reply_owner
    return if @reply.can_be_deleted_by?(current_user)

    redirect_to @community_thread.community, alert: '権限がありません'
  end

  def reply_params
    params.require(:reply).permit(:description)
  end
end
