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

  def post_thumbnail_tag(post, html_options: {}, placeholder_height: '200px')
    if post&.image&.attached?
      return post_image_tag(post, html_options: html_options, placeholder_height: placeholder_height)
    end

    if post&.youtube_url.present?
      youtube_id = extract_youtube_id(post.youtube_url)
      if youtube_id
        return youtube_thumbnail_tag(youtube_id, post.title, html_options: html_options,
                                                             placeholder_height: placeholder_height)
      end
    end

    nil
  end

  # YouTube動画IDを抽出
  def extract_youtube_id(url)
    return nil if url.blank?

    patterns = [
      %r{(?:youtube\.com/watch\?v=|youtu\.be/)([^&?/]+)},
      %r{youtube\.com/embed/([^&?/]+)},
      %r{youtube\.com/v/([^&?/]+)}
    ]

    patterns.each do |pattern|
      match = url.match(pattern)
      return match[1] if match
    end

    nil
  end

  # YouTubeサムネイル画像を表示
  def youtube_thumbnail_tag(video_id, alt_text = '', html_options: {}, placeholder_height: '200px')
    thumbnail_url = "https://img.youtube.com/vi/#{video_id}/hqdefault.jpg"

    default_class = 'card-img-top img-fluid'
    default_style = "object-fit: cover; max-height: #{placeholder_height}; width: 100%;"

    custom_class = html_options.delete(:class) || ''
    custom_style = html_options.delete(:style) || ''

    merged_class = [default_class, custom_class].compact_blank.join(' ')
    merged_style = custom_style.presence || default_style

    default_options = {
      class: merged_class,
      style: merged_style,
      alt: alt_text,
      loading: 'lazy'
    }

    image_tag(thumbnail_url, default_options.merge(html_options))
  end
end
