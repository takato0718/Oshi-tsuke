module PostsAvatarHelper
  # ユーザーのアバター画像を表示するヘルパー（Active Storage対応）
  def user_avatar_tag(user, size: 32, **html_options)
    merged_class, merged_style = build_avatar_options(size, html_options)

    if user.profile_image.attached?
      render_active_storage_avatar(user, size, merged_class, merged_style, html_options)
    elsif user.avatar_url.present?
      render_url_avatar(user, merged_class, merged_style, html_options)
    elsif user.profile_image.present?
      render_legacy_avatar(user, merged_class, merged_style, html_options)
    else
      render_default_avatar(size, merged_class, merged_style, html_options)
    end
  end

  private

  # アバターのクラスとスタイルをマージ
  def build_avatar_options(size, html_options)
    default_class = 'rounded-circle'
    default_style = "width: #{size}px; height: #{size}px; object-fit: cover; aspect-ratio: 1 / 1; flex-shrink: 0;"

    custom_class = html_options.delete(:class) || ''
    custom_style = html_options.delete(:style) || ''

    merged_class = [default_class, custom_class].compact_blank.join(' ')
    merged_style = custom_style.presence || default_style

    [merged_class, merged_style]
  end

  # Active Storageのアバターを表示
  def render_active_storage_avatar(user, size, merged_class, merged_style, html_options)
    # 正方形にリサイズ（resize_to_fillで中央からクロップ）
    variant = user.profile_image.variant(resize_to_fill: [size * 2, size * 2])
    image_tag(variant, {
      class: merged_class,
      style: merged_style,
      alt: user.name
    }.merge(html_options))
  end

  # OAuthのavatar_urlを表示
  def render_url_avatar(user, merged_class, merged_style, html_options)
    image_tag(user.avatar_url, {
      class: merged_class,
      style: merged_style,
      alt: user.name
    }.merge(html_options))
  end

  # 従来のURL形式のprofile_imageを表示（後方互換性のため）
  def render_legacy_avatar(user, merged_class, merged_style, html_options)
    image_tag(user.profile_image, {
      class: merged_class,
      style: merged_style,
      alt: user.name
    }.merge(html_options))
  end

  # デフォルトのアバターを表示
  def render_default_avatar(size, merged_class, merged_style, html_options)
    content_tag(:div, {
      class: "#{merged_class} bg-secondary d-flex align-items-center justify-content-center",
      style: merged_style
    }.merge(html_options)) do
      content_tag(:i, '', class: 'bi bi-person text-white', style: "font-size: #{size * 0.6}px;")
    end
  end
end
