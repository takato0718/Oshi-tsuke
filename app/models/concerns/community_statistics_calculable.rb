module CommunityStatisticsCalculable
  extend ActiveSupport::Concern

  # スレッド数を取得
  def threads_count
    community_threads.count
  end

  # レス数を取得
  delegate :count, to: :replies, prefix: true

  # 総投稿数（スレッド + レス）を取得
  def total_posts_count
    threads_count + replies_count
  end

  # メンバー数を取得（承認済みのみ）
  def members_count
    active_members.count
  end

  # 活発度スコアを計算（投稿数 + レス数）
  def activity_score
    # スレッド数 * 2 + レス数
    (threads_count * 2) + replies_count
  end

  # 最近の活動度（過去7日間の投稿数）
  def recent_activity_count(days: 7)
    since = days.days.ago
    threads = community_threads.where(created_at: since..).count
    replies_count = replies.where(created_at: since..).count
    threads + replies_count
  end

  # 活発度バッジ用のレベル判定
  def activity_level
    score = activity_score
    case score
    when 0..10
      'low'
    when 11..50
      'medium'
    when 51..200
      'high'
    else
      'very_high'
    end
  end
end
