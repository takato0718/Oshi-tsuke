module CrawlerHandler
  extend ActiveSupport::Concern

  included do
    # コントローラーのアクション実行前にログを出力
    before_action :log_request_info
    before_action :set_crawler_flag
  end

  private

  # リクエスト情報をログに出力
  def log_request_info
    Rails.logger.info '========================================='
    Rails.logger.info "User-Agent: #{request.user_agent}"
    Rails.logger.info "IP Address: #{request.remote_ip}"
    Rails.logger.info "Referer: #{request.referer}"
    Rails.logger.info "Request Format: #{request.format}"

    # クローラーかどうかを判定してログに記録
    Rails.logger.warn "🤖 CRAWLER DETECTED: #{request.user_agent}" if crawler?(request.user_agent)

    Rails.logger.info '========================================='
  end

  # クローラーフラグを設定
  def set_crawler_flag
    @is_crawler = crawler?(request.user_agent)
  end

  # クローラーかどうかを判定
  def crawler?(user_agent)
    return false if user_agent.blank?

    # クローラーのリスト
    crawler_patterns = %w[
      bot
      crawler
      spider
      scraper
      SERankingBacklinksBot
      Amazonbot
      Googlebot
      bingbot
      Yahoo
      Slurp
      DuckDuckBot
      Baiduspider
      YandexBot
      Sogou
      Exabot
      facebot
      ia_archiver
    ]

    # User-Agent にクローラーのパターンが含まれているか確認
    crawler_patterns.any? { |pattern| user_agent.match?(/#{pattern}/i) }
  end
end
