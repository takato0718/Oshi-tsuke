module PostsHelper
  def post_image_tag(post, html_options: {}, placeholder_height: "200px")
    return nil unless post.image.present?
      
    default_options = {
      class: "card-img-top",
      style: "object-fit: cover; height: #{placeholder_height};",
      alt: post.title
    }
    image_tag(post.image, default_options.merge(html_options))
  end
end
