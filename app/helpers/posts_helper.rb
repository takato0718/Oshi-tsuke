module PostsHelper
  # ユーザーのアバター画像を表示するヘルパー
  def user_avatar_tag(user, size: 32, **html_options)
    default_class = "rounded-circle"
    default_style = "width: #{size}px; height: #{size}px; object-fit: cover;"
    
    custom_class = html_options.delete(:class) || ""
    custom_style = html_options.delete(:style) || ""
    
    merged_class = [default_class, custom_class].reject(&:blank?).join(" ")
    merged_style = custom_style.present? ? custom_style : default_style
    
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
        content_tag(:i, "", class: "bi bi-person text-white", style: "font-size: #{size * 0.6}px;")
      end
    end
  end

    # 投稿画像表示ヘルパー
  def post_image_tag(post, html_options: {}, placeholder_height: "200px")
    # 画像がある場合のみHTMLを返す、ない場合はnilを返す
    return nil unless post&.image&.present?

    default_options = {
      class: "card-img-top",
      style: "object-fit: cover; height: #{placeholder_height};",
      alt: post.title
    }
    image_tag(post.image, default_options.merge(html_options))
  rescue => e
    Rails.logger.error "Error in post_image_tag: #{e.message}"
    nil  # エラー時もnilを返して画像部分を非表示にする
  end

  # カテゴリーナビゲーション用ヘルパー↓

  # 現在選択されているカテゴリID配列
  def selected_category_ids
    @selected_category_ids || []
  end

  # 現在の検索条件パラメータ
  def current_search_params
    params_hash = {}
    if params[:q].present? && params[:q][:title_or_description_cont].present?
      params_hash[:q] = { title_or_description_cont: params[:q][:title_or_description_cont] }
    end
    params_hash
  end

  # カテゴリーが選択されているかどうか
  def category_selected?(category_id)
    selected_category_ids.include?(category_id)
  end

  # カテゴリーのトグル後のパラメータを生成
  def category_params_for(category)
    is_selected = category_selected?(category.id)
  # 未選択のボタンが押されたら選択済みに選択済みボタンが押されたら未選択状態に戻る。これをトグルという。
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
  def category_button_class(category)
    base_class = "btn btn-sm"
    active_class = category_selected?(category.id) ? "btn-primary" : "btn-outline-primary"
    "#{base_class} #{active_class}"
  end

  # 「全て」ボタンのクラス
  def category_all_button_class
    base_class = "btn btn-sm"
    active_class = selected_category_ids.empty? && params[:q].blank? ? "btn-primary" : "btn-outline-primary"
    "#{base_class} #{active_class}"
  end
end