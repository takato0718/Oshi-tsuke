module ApplicationHelper
  # 推奨のステータスバッジを返す
  def recommendation_status_badge(recommendation)
    if recommendation.skipped?
      content_tag(:span, class: 'badge bg-secondary me-2') do
        concat tag.i('', class: 'bi bi-skip-forward')
        concat ' スキップ'
      end
    elsif recommendation.favorited?
      content_tag(:span, class: 'badge bg-success me-2') do
        concat tag.i('', class: 'bi bi-heart-fill')
        concat ' 発見'
      end
    else
      content_tag(:span, class: 'badge bg-warning me-2') do
        concat tag.i('', class: 'bi bi-clock')
        concat ' 未選択'
      end
    end
  end
end
