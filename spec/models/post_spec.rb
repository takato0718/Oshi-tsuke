require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'バリデーション' do
    it 'タイトル、説明、ユーザーがあれば有効' do
      post = build(:post)
      expect(post).to be_valid
    end

    it 'タイトルがなければ無効' do
      post = build(:post, title: nil)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include('を入力してください')
    end

    it '説明がなければ無効' do
      post = build(:post, description: nil)
      expect(post).not_to be_valid
      expect(post.errors[:description]).to include('を入力してください')
    end

    it 'タイトルが255文字を超えると無効' do
      post = build(:post, title: 'a' * 256)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include('は255文字以内で入力してください')
    end

    it '有効なYouTube URLを受け入れる' do
      post = build(:post, youtube_url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ')
      expect(post).to be_valid
    end

    it '有効なYouTube短縮URLを受け入れる' do
      post = build(:post, youtube_url: 'https://youtu.be/dQw4w9WgXcQ')
      expect(post).to be_valid
    end

    it '無効なYouTube URLを拒否する' do
      post = build(:post, youtube_url: 'https://example.com/video')
      expect(post).not_to be_valid
      expect(post.errors[:youtube_url]).to include('は有効なYouTube URLである必要があります')
    end

    it '有効な画像URLを受け入れる' do
      post = build(:post, image: 'https://example.com/image.jpg')
      expect(post).to be_valid
    end

    it '無効な画像URLを拒否する' do
      post = build(:post, image: 'not-a-url')
      expect(post).not_to be_valid
    end

    it '無効な拡張子の画像URLを拒否する' do
      post = build(:post, image: 'https://example.com/image.txt')
      expect(post).not_to be_valid
    end
  end

  describe 'アソシエーション' do
    it 'ユーザーに属する' do
      post = create(:post)
      expect(post).to respond_to(:user)
    end

    it '推し紹介を持つ' do
      post = create(:post)
      expect(post).to respond_to(:recommendations)
    end

    it 'リアクションを持つ' do
      post = create(:post)
      expect(post).to respond_to(:reactions)
    end

    it 'いいねを持つ' do
      post = create(:post)
      expect(post).to respond_to(:likes)
    end

    it 'コメントを持つ' do
      post = create(:post)
      expect(post).to respond_to(:comments)
    end
  end

  describe 'メソッド' do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user) }

    it '所有者を正しく判定する' do
      expect(post.owned_by?(user)).to be true
    end

    it '非所有者を正しく判定する' do
      other_user = create(:user)
      expect(post.owned_by?(other_user)).to be false
    end

    it 'いいねされていない場合、liked_by?はfalseを返す' do
      other_user = create(:user)
      expect(post.liked_by?(other_user)).to be false
    end

    it 'いいね数を正しく返す' do
      other_user = create(:user)
      create(:reaction, :like, user: other_user, post: post)
      expect(post.likes_count).to eq(1)
    end
  end
end

