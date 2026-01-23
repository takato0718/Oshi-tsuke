module PostsHelper
  # ユーザーのアバター画像を表示するヘルパー
  def user_avatar_tag(user, size: 32, **html_options)
    default_class = 'rounded-circle'
    default_style = "width: #{size}px; height: #{size}px; object-fit: cover;"

    custom_class = html_options.delete(:class) || ''
    custom_style = html_options.delete(:style) || ''

    merged_class = [default_class, custom_class].compact_blank.join(' ')
    merged_style = custom_style.presence || default_style

    if user.profile_image.present?
      image_tag(user.profile_image, {
        class: merged_class,
        style: merged_style,
        alt: user.name
      }.merge(html_options))
    else
      content_tag(:div, {
        class: "#{merged_class} bg-secondary d-flex align-items-center justify-content-center",
        style: merged_style
      }.merge(html_options)) do
        content_tag(:i, '', class: 'bi bi-person text-white', style: "font-size: #{size * 0.6}px;")
      end
    end
  end

  # 投稿画像表示ヘルパー（Active Storage）
  def post_image_tag(post, html_options: {}, placeholder_height: '200px')
    # 画像がある場合のみHTMLを返す、ない場合はnilを返す
    return nil unless post&.image&.attached?

    variant = post.image.variant(resize_to_limit: [1200, 800]).processed

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

  # --- カテゴリーナビゲーション用ヘルパー ---

  # 現在選択されているカテゴリID配列
  def selected_category_ids(selected_ids = nil)
    selected_ids || []
  end

  # 現在の検索条件パラメータ
  def current_search_params
    {}
  end

  # カテゴリーが選択されているかどうか
  def category_selected?(category_id, selected_category_ids = [])
    selected_category_ids.include?(category_id)
  end

  # カテゴリーのトグル後のパラメータを生成
  def category_params_for(category, selected_category_ids = [])
    is_selected = category_selected?(category.id, selected_category_ids)
    new_category_ids =
      if is_selected
        selected_category_ids - [category.id]
      else
        selected_category_ids + [category.id]
      end

    params = current_search_params.dup
    params[:category] = new_category_ids if new_category_ids.any?
    params
  end

  # カテゴリーボタンのクラスを返す
  def category_button_class(category, selected_category_ids = [])
    base_class = 'btn btn-sm'
    active_class = category_selected?(category.id, selected_category_ids) ? 'btn-primary' : 'btn-outline-primary'
    "#{base_class} #{active_class}"
  end

  # 「全て」ボタンのクラス
  def category_all_button_class(selected_category_ids = [])
    base_class = 'btn btn-sm'
    active_class = selected_category_ids.to_a.empty? && params[:q].blank? ? 'btn-primary' : 'btn-outline-primary'
    "#{base_class} #{active_class}"
  end

  # --- 推し発見履歴用ヘルパー ---

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
