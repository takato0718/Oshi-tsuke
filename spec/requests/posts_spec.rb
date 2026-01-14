require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:post_record) { create(:post, user: user) } # ← post ではなく post_record

  describe 'GET /posts' do
    it '一覧ページが表示される' do
      host! 'www.example.com'
      get posts_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /posts/:id' do
    it '詳細ページが表示される' do
      get post_path(post_record) # ← post_record を使用
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /posts/new' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '新規投稿ページが表示される' do
        get new_post_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトされる' do
        get new_post_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'POST /posts' do
    context 'ログインしている場合' do
      before { login_as(user) }

      it '投稿が作成される' do
        expect do
          post posts_path, params: { post: { title: 'New Post', description: 'New Description' } }
        end.to change(Post, :count).by(1)
        expect(response).to redirect_to(Post.last)
      end
    end

    context 'ログインしていない場合' do
      it '投稿が作成されない' do
        expect do
          post posts_path, params: { post: { title: 'New Post', description: 'New Description' } }
        end.not_to(change(Post, :count))
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'GET /posts/:id/edit' do
    context '所有者の場合' do
      before { login_as(user) }

      it '編集ページが表示される' do
        get edit_post_path(post_record)  # ← post_record を使用
        expect(response).to have_http_status(:success)
      end
    end

    context '非所有者の場合' do
      before { login_as(other_user) }

      it '一覧ページにリダイレクトされる' do
        get edit_post_path(post_record)  # ← post_record を使用
        expect(response).to redirect_to(posts_path)
      end
    end
  end

  describe 'PATCH /posts/:id' do
    context '所有者の場合' do
      before { login_as(user) }

      it '投稿が更新される' do
        patch post_path(post_record), params: { post: { title: 'Updated Title', description: 'Updated Description' } }
        expect(response).to redirect_to(post_record)
        post_record.reload
        expect(post_record.title).to eq('Updated Title')
      end
    end

    context '非所有者の場合' do
      before { login_as(other_user) }

      it '投稿が更新されない' do
        original_title = post_record.title
        patch post_path(post_record), params: { post: { title: 'Updated Title' } }
        expect(response).to redirect_to(posts_path)
        post_record.reload
        expect(post_record.title).to eq(original_title)
      end
    end
  end

  describe 'DELETE /posts/:id' do
    context '所有者の場合' do
      before { login_as(user) }

      it '投稿が削除される' do
        post_record  # ← 先に作成
        expect do
          delete post_path(post_record)
        end.to change(Post, :count).by(-1)
        expect(response).to redirect_to(posts_path)
      end
    end

    context '非所有者の場合' do
      before { login_as(other_user) }

      it '投稿が削除されない' do
        post_record  # ← 先に作成
        expect do
          delete post_path(post_record)
        end.not_to(change(Post, :count))
        expect(response).to redirect_to(posts_path)
      end
    end
  end
end
