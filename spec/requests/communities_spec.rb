require 'rails_helper'

RSpec.describe 'Communities', type: :request do
  let(:user) { create(:user) }
  let(:community) { create(:community) }

  describe 'GET /communities' do
    before do
      login_as(user) # ← ログインを追加

      # デバッグ用のログを追加
      Rails.logger.debug "\n=== ログイン後のステータス ==="
      Rails.logger.debug { "Response status: #{response.status}" }
      Rails.logger.debug { "Response location: #{response.location}" }
      Rails.logger.debug 'Response body (最初の300文字):'
      Rails.logger.debug response.body[0..300]
      Rails.logger.debug "===========================\n"
    end

    it '一覧ページが表示される' do
      get communities_path

      Rails.logger.debug "\n=== communities_path アクセス後 ==="
      Rails.logger.debug { "Response status: #{response.status}" }
      Rails.logger.debug 'Response body (最初の300文字):'
      Rails.logger.debug response.body[0..300]
      Rails.logger.debug "===========================\n"

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /communities/:id' do
    before { login_as(user) }  # ← ログインを追加

    it '詳細ページが表示される' do
      get community_path(community)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /communities/ranking' do
    before { login_as(user) }  # ← ログインを追加

    it 'ランキングページが表示される' do
      get ranking_communities_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /communities/new' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '新規コミュニティページが表示される' do
        get new_community_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされる' do
        get new_community_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'POST /communities' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it 'コミュニティが作成される' do
        expect do
          post communities_path, params: { community: { name: 'テストコミュニティ', description: '説明', is_public: true } }
        end.to change(Community, :count).by(1)
      end
    end

    context 'ログインしていない場合' do
      it 'コミュニティが作成されない' do
        expect do
          post communities_path, params: { community: { name: 'テストコミュニティ', description: '説明', is_public: true } }
        end.not_to change(Community, :count)
      end
    end
  end

  describe 'POST /communities/:id/join' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '公開コミュニティに参加できる' do
        expect do
          post join_community_path(community)
        end.to change(CommunityMembership, :count).by(1)
      end
    end

    context 'ログインしていない場合' do
      it '参加できない' do
        expect do
          post join_community_path(community)
        end.not_to change(CommunityMembership, :count)
      end
    end
  end

  describe 'DELETE /communities/:id/leave' do
    let!(:membership) { create(:community_membership, user: user, community: community) }

    context 'メンバーの場合' do
      before { login_as(user) }

      it 'コミュニティから脱退できる' do
        expect do
          delete leave_community_path(community)
        end.to change(CommunityMembership, :count).by(-1)
      end
    end
  end
end
