class StaticPagesController < ApplicationController
  skip_before_action :require_login, only: [:terms, :privacy] 

  def terms
  end

  def privacy
    # プライバシーポリシーページ
  end
end
