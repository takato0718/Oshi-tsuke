require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it '名前、メール、パスワードがあれば有効' do
      user = build(:user)
      expect(user).to be_valid
    end

    it '名前がなければ無効' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include('を入力してください')
    end

    it 'メールアドレスがなければ無効' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('を入力してください')
    end

    it 'メールアドレスが一意でなければ無効' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'パスワードが6文字未満なら無効' do
      user = build(:user, password: 'short', password_confirmation: 'short')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('は6文字以上で入力してください')
    end

    it 'パスワードとパスワード確認が一致しなければ無効' do
      user = build(:user, password: 'password123', password_confirmation: 'different')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to be_present
    end
  end

  describe 'アソシエーション' do
    it '投稿を持つ' do
      user = create(:user)
      expect(user).to respond_to(:posts)
    end

    it 'コミュニティを持つ' do
      user = create(:user)
      expect(user).to respond_to(:communities)
    end

    it '推し紹介を持つ' do
      user = create(:user)
      expect(user).to respond_to(:recommendations)
    end

    it 'リアクションを持つ' do
      user = create(:user)
      expect(user).to respond_to(:reactions)
    end

    it 'ユーザーを削除すると関連する投稿も削除される' do
      user = create(:user)
      post = create(:post, user: user)
      
      expect {
        user.destroy
      }.to change { Post.count }.by(-1)
    end

    it 'ユーザーを削除すると関連するコミュニティも削除される' do
      user = create(:user)
      community = create(:community, creator: user)
      
      expect {
        user.destroy
      }.to change { Community.count }.by(-1)
    end
  end
end

