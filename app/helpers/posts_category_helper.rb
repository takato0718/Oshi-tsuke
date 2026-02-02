module PostsCategoryHelper
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
end
