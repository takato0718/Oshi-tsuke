module PostsHelper
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
  end