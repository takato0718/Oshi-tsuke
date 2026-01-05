module CommunitiesHelper
  def render_report_modals_for_thread(thread)
    return unless logged_in?
        
    modals = []
        
    # スレッドの報告モーダル
    if thread.user != current_user
      modals << render('shared/report_modal', reportable: thread)
    end
        
    # レスの報告モーダル
    thread.replies.each do |reply|
      if reply.user != current_user
        modals << render('shared/report_modal', reportable: reply)
      end
    end
        
    safe_join(modals)
  end
end