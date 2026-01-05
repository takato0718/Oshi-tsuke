class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :review, :dismiss]
  before_action :check_moderator_for_review, only: [:review, :dismiss]

  def index
    # モデレーターまたは管理者のみが閲覧可能
    unless logged_in?
        redirect_to root_path, alert: 'ログインが必要です'
        return
      end
      
      # ユーザーがモデレーターまたは管理者であるコミュニティの報告のみ表示
      moderatable_community_ids = current_user.moderatable_community_ids
  
      if moderatable_community_ids.empty?
        redirect_to root_path, alert: 'モデレーター権限がありません'
        return
      end
      
      # スレッドとレスの報告を取得
      @reports = Report.for_communities(moderatable_community_ids)
                       .recent
                       .page(params[:page])
                       .per(20)
  end
    
  def show
  end
    
  def create
    reportable_type = params[:reportable_type]
    reportable_id = params[:reportable_id]
    reason = params[:reason]
      
    # 報告可能なタイプのみ許可（コミュニティ内の投稿のみ）
    unless ['CommunityThread', 'Reply'].include?(reportable_type)
      redirect_back(fallback_location: root_path, alert: '報告できないコンテンツです')
      return
    end
      
    # reportableオブジェクトを取得
    reportable = reportable_type.constantize.find(reportable_id)
      
    @report = current_user.reports.build(
      reportable: reportable,
      reason: reason
    )
      
    if @report.save
      redirect_back(fallback_location: root_path, notice: '報告しました。ありがとうございます。')
    else
      redirect_back(fallback_location: root_path, alert: "報告に失敗しました: #{@report.errors.full_messages.join(', ')}")
    end
  end
    
  def review
    notes = params[:notes]
    resolved = params[:resolved] == 'true'
      
    @report.review!(reviewer: current_user, notes: notes, resolved: resolved)
      
    # 解決済みの場合、報告対象を削除
    if resolved && @report.reportable.present?
      @report.reportable.destroy
    end
      
    redirect_to reports_path, notice: '報告をレビューしました'
  end
    
  def dismiss
    notes = params[:notes]

    @report.dismiss!(reviewer: current_user, notes: notes)

    redirect_to reports_path, notice: '報告を却下しました'
  end

  private

  def set_report
    @report = Report.find(params[:id])
  end
    
  def check_moderator_for_review
    # 報告対象のコミュニティでモデレーター権限があるかチェック
    community = case @report.reportable_type
                when 'CommunityThread'
                  @report.reportable.community
                when 'Reply'
                  @report.reportable.community_thread.community
                end
      
    unless community && community.can_moderate?(current_user)
      redirect_to reports_path, alert: '権限がありません'
    end
  end
end
  