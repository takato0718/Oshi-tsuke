require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /users/:id' do
    it '詳細ページが表示される' do
      get user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /users/:id/edit' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '編集ページが表示される' do
        get edit_user_path(user)
        expect(response).to have_http_status(:success)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされる' do
        get edit_user_path(user)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'PATCH /users/:id' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it 'ユーザー情報が更新される' do
        patch user_path(user), params: { user: { name: 'Updated Name' } }
        expect(response).to redirect_to(user)
        user.reload
        expect(user.name).to eq('Updated Name')
      end
    end

    context 'ログインしていない場合' do
      it 'ユーザー情報が更新されない' do
        original_name = user.name
        patch user_path(user), params: { user: { name: 'Updated Name' } }
        expect(response).to redirect_to(new_session_path)
        user.reload
        expect(user.name).to eq(original_name)
      end
    end
  end

  describe 'GET /users/:id/recommendations' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '推し紹介一覧ページが表示される' do
        get recommendations_user_path(user)
        expect(response).to have_http_status(:success)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされる' do
        get recommendations_user_path(user)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /users/:id' do
    it '詳細ページが表示される' do
      get user_path(user)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /users/:id/edit' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '編集ページが表示される' do
        get edit_user_path(user)
        expect(response).to have_http_status(:success)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされる' do
        get edit_user_path(user)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'PATCH /users/:id' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it 'ユーザー情報が更新される' do
        patch user_path(user), params: { user: { name: 'Updated Name' } }
        expect(response).to redirect_to(user)
        user.reload
        expect(user.name).to eq('Updated Name')
      end
    end

    context 'ログインしていない場合' do
      it 'ユーザー情報が更新されない' do
        original_name = user.name
        patch user_path(user), params: { user: { name: 'Updated Name' } }
        expect(response).to redirect_to(new_session_path)
        user.reload
        expect(user.name).to eq(original_name)
      end
    end
  end

  describe 'GET /users/:id/recommendations' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '推し紹介一覧ページが表示される' do
        get recommendations_user_path(user)
        expect(response).to have_http_status(:success)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされる' do
        get recommendations_user_path(user)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end

