class RepliesController < ApplicationController
  before_action :set_community_thread
  before_action :check_community_member
  
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
  
  private
  
  def set_community_thread
    @community_thread = CommunityThread.find(params[:community_thread_id])
  end
  
  def check_community_member
    unless @community_thread.community.member?(current_user)
      redirect_to @community_thread.community, alert: 'このコミュニティのメンバーのみ投稿できます'
    end
  end
  
  def reply_params
    params.require(:reply).permit(:description)
  end
end
  