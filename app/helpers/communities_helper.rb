module CommunitiesHelper
  def render_report_modals_for_thread(thread)
    return unless logged_in?

    modals = []

    # スレッドの報告モーダル
    modals << render('shared/report_modal', reportable: thread) if thread.user != current_user

    # レスの報告モーダル
    thread.replies.each do |reply|
      modals << render('shared/report_modal', reportable: reply) if reply.user != current_user
    end

    safe_join(modals)
  end

  # 活発度レベルのバッジクラスを返す
  def activity_level_badge_class(level)
    case level
    when 'very_high'
      'bg-danger'
    when 'high'
      'bg-warning'
    when 'medium'
      'bg-info'
    else
      'bg-secondary'
    end
  end

  # 活発度レベルの日本語表示
  def activity_level_text(level)
    case level
    when 'very_high'
      '非常に活発'
    when 'high'
      '活発'
    when 'medium'
      '普通'
    else
      '低調'
    end
  end
end
