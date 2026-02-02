class ReportsController < ApplicationController
  before_action :set_report, only: %i[review dismiss]
  before_action :check_moderator_for_review, only: %i[review dismiss]

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

    # コミュニティIDを取得（戻るボタン用）
    @community_id = params[:community_id]
    @community = Community.find_by(uuid: @community_id) if @community_id.present?

    # スレッドとレスの報告を取得
    @reports = Report.for_communities(moderatable_community_ids)
                     .recent
                     .page(params[:page])
                     .per(20)
  end

  def create
    reportable_type = params[:reportable_type]
    reportable_id = params[:reportable_id]
    reason = params[:reason]

    # 報告可能なタイプのみ許可（コミュニティ内の投稿のみ）
    unless %w[CommunityThread Reply].include?(reportable_type)
      redirect_back_or_to(root_path, alert: '報告できないコンテンツです')
      return
    end

    # reportableオブジェクトを取得
    reportable = reportable_type.constantize.find(reportable_id)

    @report = current_user.reports.build(
      reportable: reportable,
      reason: reason
    )

    community = find_community_from_reportable(reportable)
    if @report.save
      # コミュニティを取得してリダイレクト
      redirect_to community_path(community), notice: '報告しました。ありがとうございます。'
    else
      # エラー時もコミュニティに戻る
      redirect_to community_path(community), alert: "報告に失敗しました: #{@report.errors.full_messages.join(', ')}"
    end
  end

  def review
    notes = params[:notes]
    resolved = params[:resolved] == 'true'

    @report.review!(reviewer: current_user, notes: notes, resolved: resolved)

    # 解決済みの場合、報告対象を削除
    @report.reportable.destroy if resolved && @report.reportable.present?

    redirect_to_reports_index(notice: '報告をレビューしました')
  end

  def dismiss
    notes = params[:notes]

    @report.dismiss!(reviewer: current_user, notes: notes)

    redirect_to_reports_index(notice: '報告を却下しました')
  end

  private

  # コミュニティの報告一覧ページにリダイレクト
  def redirect_to_reports_index(notice:)
    community = find_community_from_report
    redirect_to reports_path(community_id: community&.uuid), notice: notice
  end

  # 報告対象からコミュニティを取得
  def find_community_from_report
    case @report.reportable_type
    when 'CommunityThread'
      @report.reportable.community
    when 'Reply'
      @report.reportable.community_thread.community
    end
  end

  # reportableオブジェクトからコミュニティを取得
  def find_community_from_reportable(reportable)
    case reportable.class.name
    when 'CommunityThread'
      reportable.community
    when 'Reply'
      reportable.community_thread.community
    end
  end

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

    return if community&.can_moderate?(current_user)

    redirect_to reports_path, alert: '権限がありません'
  end
end
