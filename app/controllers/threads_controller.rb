class ThreadsController < ApplicationController
  before_action :set_community
  before_action :check_community_member

  # POST /communities/:community_id/threads
  def create
    @thread = current_user.community_threads.build(
      description: thread_params[:description],
      community_id: @community.id
    )

    if @thread.save
      redirect_to @community, notice: 'スレッドを立てました！'
    else
      error_messages = @thread.errors.full_messages.join(', ')
      redirect_to @community, alert: "スレッドの作成に失敗しました: #{error_messages}"
    end
  end

  private

  def set_community
    @community = Community.find_by!(uuid: params[:community_id])
  end

  def check_community_member
    return if @community.member?(current_user)

    redirect_to @community, alert: 'このコミュニティのメンバーのみ投稿できます'
  end

  def thread_params
    params.require(:thread).permit(:description)
  end
end
