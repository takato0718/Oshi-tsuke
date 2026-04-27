module TwitterShareHelper
  # 投稿詳細画面用のシェアURL
  def post_twitter_share_url(post)
    user_name = post.user.name
    text = "#{user_name}の推し、「#{post.title}」を紹介します！ #推しツケ"
    url = post_url(post)

    "https://twitter.com/intent/tweet?text=#{CGI.escape(text)}&url=#{CGI.escape(url)}"
  end

  # 推し紹介された時のシェアURL
  def recommendation_twitter_share_url(recommendation)
    post = recommendation.post
    recommender = post.user

    text = "#{recommender.name}さんから「#{post.title}」を推しツケられました！ #推しツケ"
    url = post_url(post)

    "https://twitter.com/intent/tweet?text=#{CGI.escape(text)}&url=#{CGI.escape(url)}"
  end
end
