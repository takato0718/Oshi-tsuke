module OgpHelper
  # OGP用の画像URLを返す（優先順位: 投稿画像 > YouTubeサムネ > デフォルト画像）
  def post_ogp_image_url(post)
    # 1. Active Storageの画像がある場合
    if post&.image&.attached?
      begin
        variant = post.image.variant(
          resize_to_limit: [1200, 630], # OGP推奨サイズ（1200x630px）
          format: :jpg
        ).processed
        return rails_blob_url(variant, only_path: false) # 絶対URLを返す
      rescue StandardError => e
        Rails.logger.error "Error generating OGP image: #{e.message}"
      end
    end

    # 2. YouTube URLがある場合
    if post&.youtube_url.present?
      youtube_id = extract_youtube_id_for_ogp(post.youtube_url)
      return "https://img.youtube.com/vi/#{youtube_id}/maxresdefault.jpg" if youtube_id
    end

    # 3. デフォルトのOGP画像（アプリのロゴなど）
    default_ogp_image_url
  end

  # デフォルトのOGP画像URL
  def default_ogp_image_url
    # app/assets/images/ogp_default.jpg を用意しておく
    asset_url('ogp_default.jpg')
  end

  # OGPのタイトルを生成
  def post_ogp_title(post)
    "#{post.title} | 推しツケ"
  end

  # OGPの説明文を生成
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
