class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true
  belongs_to :reviewed_by, class_name: "User", optional: true
    
  # 報告の状態
  enum status: {
    pending: 0,    # 未対応
    reviewed: 1,   # レビュー済み
    resolved: 2,   # 解決済み（削除など）
    dismissed: 3   # 却下（問題なし）
  }
    
  validates :reason, presence: true, length: { maximum: 1000 }
  validates :status, presence: true
    
  scope :pending, -> { where(status: :pending) }
  scope :recent, -> { order(created_at: :desc) }

  # スレッドへの報告で、指定されたコミュニティに属するもの
  scope :for_community_threads, ->(community_ids) {
    where(reportable_type: 'CommunityThread')
      .joins('INNER JOIN community_threads ON community_threads.id = reports.reportable_id')
      .where(community_threads: { community_id: community_ids })
  }
  
  # レスへの報告で、指定されたコミュニティに属するもの
  scope :for_community_replies, ->(community_ids) {
    where(reportable_type: 'Reply')
      .joins('INNER JOIN replies ON replies.id = reports.reportable_id')
      .joins('INNER JOIN community_threads ON community_threads.id = replies.community_thread_id')
      .where(community_threads: { community_id: community_ids })
  }
  
  # 指定されたコミュニティに関する全ての報告（スレッド + レス）
  scope :for_communities, ->(community_ids) {
    # 空の配列が渡された場合は空のリレーションを返す
    return none if community_ids.blank?
    
    # スレッドとレスの報告をUNIONで結合
    thread_sql = for_community_threads(community_ids).to_sql
    reply_sql = for_community_replies(community_ids).to_sql
    
    from("(#{thread_sql} UNION #{reply_sql}) AS reports")
  }
    
  # ステータスの日本語表示
  def status_i18n
    case status
    when 'pending'
      '未対応'
    when 'reviewed'
      'レビュー済み'
    when 'resolved'
      '解決済み'
    when 'dismissed'
      '却下'
    else
      status
    end
  end
    
  # 報告対象タイプの日本語表示
  def reportable_type_i18n
    case reportable_type
    when 'CommunityThread'
      'スレッド'
    when 'Reply'
      'レス'
    else
      reportable_type
    end
  end
    
  # レビュー処理
  def review!(reviewer:, notes: nil, resolved: false)
    update!(
      reviewed_by: reviewer,
      review_notes: notes,
      reviewed_at: Time.current,
      status: resolved ? :resolved : :reviewed
    )
  end
    
  # 却下処理
  def dismiss!(reviewer:, notes: nil)
    update!(
      reviewed_by: reviewer,
      review_notes: notes,
      reviewed_at: Time.current,
      status: :dismissed
    )
  end
end