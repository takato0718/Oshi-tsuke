require 'rails_helper'

RSpec.describe 'Recommendations', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:post_record) { create(:post, user: other_user) }

  describe 'GET /recommendations/daily' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '今日の推し紹介ページが表示される' do
        # ★ ここで recommendation を作成
        create(:recommendation, user: user, post: post_record, status: :pending)
        
        get daily_recommendations_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされる' do
        get daily_recommendations_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'PATCH /recommendations/:id/skip' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '推し紹介がスキップされる' do
        recommendation = create(:recommendation, user: user, post: post_record, status: :pending)

        patch skip_recommendation_path(recommendation), headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:success)

        recommendation.reload
        expect(recommendation.skipped?).to be true
      end
    end
  end

  describe 'PATCH /recommendations/:id/favorite' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '推し紹介がお気に入りされる' do
        recommendation = create(:recommendation, user: user, post: post_record, status: :pending)

        patch favorite_recommendation_path(recommendation), headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:success)

        recommendation.reload
        expect(recommendation.favorited?).to be true
      end
    end
  end
end
