module OgpHelper
  # OGP用の画像URLを返す（優先順位: 投稿画像 > YouTubeサムネ > デフォルト画像）
  def post_ogp_image_url(post)
    if post&.image&.attached?
      begin
        variant = post.image.variant(
          resize_to_limit: [1200, 630],
          format: :jpg
        ).processed
        return rails_blob_url(variant, only_path: false)
      rescue StandardError => e
        Rails.logger.error "Error generating OGP image: #{e.message}"
      end
    end

    if post&.youtube_url.present?
      youtube_id = extract_youtube_id_for_ogp(post.youtube_url)
      return "https://img.youtube.com/vi/#{youtube_id}/maxresdefault.jpg" if youtube_id
    end

    default_ogp_image_url
  end

  # デフォルトのOGP画像URL
  def default_ogp_image_url
    asset_url('ogp.png')
  end

  def post_ogp_title(post)
    "#{post.title} | 推しツケ"
  end

  def post_ogp_description(post)
    post.description&.truncate(100) || '推しツケで素敵な推しを発見！'
  end

  private

  # YouTube動画IDを抽出（OGP用）
  def extract_youtube_id_for_ogp(url)
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
end
