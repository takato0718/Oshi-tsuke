class CommunityModerationsController < ApplicationController
  before_action :set_community
  before_action :check_moderator_access

  # メンバーシップ承認
  def approve_membership
    membership = @community.community_memberships.find(params[:id])

    if membership.approve!
      redirect_to @community, notice: "#{membership.user.name}さんの参加を承認しました"
    else
      redirect_to @community, alert: '承認に失敗しました'
    end
  end

  # 権限変更
  def change_role
    membership = @community.community_memberships.find(params[:id])
    new_role = params[:role]

    # 管理者のみが権限変更可能
    unless @community.admin?(current_user)
      redirect_to @community, alert: '権限がありません'
      return
    end

    # 作成者の権限は変更できない
    if membership.user == @community.creator
      redirect_to @community, alert: 'コミュニティ作成者の権限は変更できません'
      return
    end

    if membership.change_role!(new_role)
      redirect_to @community, notice: "#{membership.user.name}さんの権限を変更しました"
    else
      redirect_to @community, alert: '権限変更に失敗しました'
    end
  end

  # スレッド削除
  def destroy_thread
    thread = @community.community_threads.find(params[:thread_id])

    unless thread.can_be_deleted_by?(current_user)
      redirect_to @community, alert: '権限がありません'
      return
    end

    thread.destroy
    redirect_to @community, notice: 'スレッドを削除しました'
  end

  # レス削除
  def destroy_reply
    reply = Reply.find(params[:reply_id])

    unless reply.community_thread.community == @community
      redirect_to @community, alert: 'このコミュニティのレスではありません'
      return
    end

    unless reply.can_be_deleted_by?(current_user)
      redirect_to @community, alert: '権限がありません'
      return
    end

    reply.destroy
    redirect_to @community, notice: 'レスを削除しました'
  end

  private

  def set_community
    @community = Community.find_by!(uuid: params[:community_id])
  end

  def check_moderator_access
    return if @community.can_moderate?(current_user)

    redirect_to @community, alert: '権限がありません'
  end
end
