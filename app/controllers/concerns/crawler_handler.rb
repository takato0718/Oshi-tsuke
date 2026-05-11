module CrawlerHandler
  extend ActiveSupport::Concern

  included do
    before_action :log_request_info
    before_action :set_crawler_flag
  end

  private

  def log_request_info
    Rails.logger.info '========================================='
    Rails.logger.info "User-Agent: #{request.user_agent}"
    Rails.logger.info "IP Address: #{request.remote_ip}"
    Rails.logger.info "Referer: #{request.referer}"
    Rails.logger.info "Request Format: #{request.format}"

    Rails.logger.warn "🤖 CRAWLER DETECTED: #{request.user_agent}" if crawler?

    Rails.logger.info '========================================='
  end

  def set_crawler_flag
    @is_crawler = crawler?
  end

  def crawler?
    return false if request.user_agent.blank?

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

    crawler_patterns.any? { |pattern| request.user_agent.match?(/#{pattern}/i) }
  end
end
