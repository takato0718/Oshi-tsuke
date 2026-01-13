require 'rails_helper'

RSpec.describe Reaction, type: :model do
  describe 'バリデーション' do
    let(:user) { create(:user) }
    let(:post) { create(:post) }

    it 'いいねの場合、有効' do
      reaction = build(:reaction, :like, user: user, post: post)
      expect(reaction).to be_valid
    end

    it 'コメントの場合、有効' do
      reaction = build(:reaction, :comment, user: user, post: post)
      expect(reaction).to be_valid
    end

    it 'ユーザーIDがなければ無効' do
      reaction = build(:reaction, user: nil)
      expect(reaction).not_to be_valid
      expect(reaction.errors[:user_id]).to include('を入力してください')
    end

    it '投稿IDがなければ無効' do
      reaction = build(:reaction, post: nil)
      expect(reaction).not_to be_valid
      expect(reaction.errors[:post_id]).to include('を入力してください')
    end

    it 'コメントの場合、内容がなければ無効' do
      reaction = build(:reaction, :comment, content: nil)
      expect(reaction).not_to be_valid
      expect(reaction.errors[:content]).to include('を入力してください')
    end

    it 'いいねの場合、内容があると無効' do
      reaction = build(:reaction, :like, content: 'Content')
      expect(reaction).not_to be_valid
      expect(reaction.errors[:content]).to include('は入力しないでください')
    end

    it '同じユーザーが同じ投稿に重複していいねできない' do
      user = create(:user)
      post = create(:post)
      create(:reaction, :like, user: user, post: post)
      
      duplicate = build(:reaction, :like, user: user, post: post)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include('は既にこの投稿にいいねをしています')
    end

    it '同じユーザーが同じ投稿に複数のコメントを付けられる' do
      user = create(:user)
      post = create(:post)
      create(:reaction, :comment, user: user, post: post, content: 'First comment')
      
      second_comment = build(:reaction, :comment, user: user, post: post, content: 'Second comment')
      expect(second_comment).to be_valid
    end
  end

  describe 'アソシエーション' do
    it 'ユーザーに属する' do
      reaction = create(:reaction)
      expect(reaction).to respond_to(:user)
    end

    it '投稿に属する' do
      reaction = create(:reaction)
      expect(reaction).to respond_to(:post)
    end
  end

  describe 'メソッド' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:post) { create(:post) }

    it 'コメントの所有者の場合、can_be_deleted_by?はtrueを返す' do
      comment = create(:reaction, :comment, user: other_user, post: post)
      expect(comment.can_be_deleted_by?(other_user)).to be true
    end

    it 'コメントの非所有者の場合、can_be_deleted_by?はfalseを返す' do
      comment = create(:reaction, :comment, user: other_user, post: post)
      expect(comment.can_be_deleted_by?(user)).to be false
    end

    it 'いいねの場合、can_be_deleted_by?はfalseを返す' do
      like = create(:reaction, :like, user: other_user, post: post)
      expect(like.can_be_deleted_by?(other_user)).to be false
    end
  end
end

