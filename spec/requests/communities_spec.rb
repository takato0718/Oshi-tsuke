require 'rails_helper'

RSpec.describe 'Communities', type: :request do
  let(:user) { create(:user) }
  let(:community) { create(:community) }

  describe 'GET /communities' do
    before do
      login_as(user)  # ← ログインを追加

      # デバッグ用のログを追加
      puts "\n=== ログイン後のステータス ==="
      puts "Response status: #{response.status}"
      puts "Response location: #{response.location}"
      puts "Response body (最初の300文字):"
      puts response.body[0..300]
      puts "===========================\n"
    end
    
    it '一覧ページが表示される' do
      get communities_path

      puts "\n=== communities_path アクセス後 ==="
      puts "Response status: #{response.status}"
      puts "Response body (最初の300文字):"
      puts response.body[0..300]
      puts "===========================\n"

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
        expect {
          post communities_path, params: { community: { name: 'テストコミュニティ', description: '説明', is_public: true } }
        }.to change(Community, :count).by(1)
      end
    end

    context 'ログインしていない場合' do
      it 'コミュニティが作成されない' do
        expect {
          post communities_path, params: { community: { name: 'テストコミュニティ', description: '説明', is_public: true } }
        }.not_to change(Community, :count)
      end
    end
  end

  describe 'POST /communities/:id/join' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '公開コミュニティに参加できる' do
        expect {
          post join_community_path(community)
        }.to change(CommunityMembership, :count).by(1)
      end
    end

    context 'ログインしていない場合' do
      it '参加できない' do
        expect {
          post join_community_path(community)
        }.not_to change(CommunityMembership, :count)
      end
    end
  end

  describe 'DELETE /communities/:id/leave' do
    let!(:membership) { create(:community_membership, user: user, community: community) }

    context 'メンバーの場合' do
      before { login_as(user) }

      it 'コミュニティから脱退できる' do
        expect {
          delete leave_community_path(community)
        }.to change(CommunityMembership, :count).by(-1)
      end
    end
  end
end