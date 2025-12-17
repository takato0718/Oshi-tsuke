module PostsHelper
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