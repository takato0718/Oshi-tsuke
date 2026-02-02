module PostsHelper
  # 投稿画像表示ヘルパー（Active Storage）
  def post_image_tag(post, html_options: {}, placeholder_height: '200px')
    # 画像がある場合のみHTMLを返す、ない場合はnilを返す
    return nil unless post&.image&.attached?

    variant = post.image.variant(
      resize_to_limit: [1200, 800],
      format: :webp
    ).processed

    # デフォルトのクラスとスタイル
    default_class = 'card-img-top img-fluid'
    default_style = "object-fit: cover; max-height: #{placeholder_height}; width: 100%;"

    # html_optionsからクラスとスタイルを取得（存在する場合）
    custom_class = html_options.delete(:class) || ''
    custom_style = html_options.delete(:style) || ''

    # クラスをマージ（デフォルト + カスタム）
    merged_class = [default_class, custom_class].compact_blank.join(' ')

    # スタイルをマージ（カスタムが優先）
    merged_style = custom_style.presence || default_style

    default_options = {
      class: merged_class,
      style: merged_style,
      alt: post.title
    }
    image_tag(variant, default_options.merge(html_options))
  rescue StandardError => e
    Rails.logger.error "Error in post_image_tag: #{e.message}"
    nil # エラー時もnilを返して画像部分を非表示にする
  end

  # 推奨のステータスバッジを返す
  def recommendation_status_badge(recommendation)
    if recommendation.skipped?
      content_tag(:span, class: 'badge bg-secondary me-2') do
        "#{tag.i('', class: 'bi bi-skip-forward')} スキップ"
      end
    elsif recommendation.favorited?
      content_tag(:span, class: 'badge bg-success me-2') do
        "#{tag.i('', class: 'bi bi-heart-fill')} 発見"
      end
    else
      content_tag(:span, class: 'badge bg-warning me-2') do
        "#{tag.i('', class: 'bi bi-clock')} 未選択"
      end
    end
  end
end
