require 'rails_helper'

RSpec.describe CommunityThread, type: :model do
  describe 'バリデーション' do
    it '説明、ユーザー、コミュニティがあれば有効' do
      thread = build(:community_thread)
      expect(thread).to be_valid
    end

    it '説明がなければ無効' do
      thread = build(:community_thread, description: nil)
      expect(thread).not_to be_valid
      expect(thread.errors[:description]).to include('を入力してください')
    end

    it 'ユーザーIDがなければ無効' do
      thread = build(:community_thread, user: nil)
      expect(thread).not_to be_valid
      expect(thread.errors[:user]).to be_present
    end

    it 'コミュニティIDがなければ無効' do
      thread = build(:community_thread, community: nil)
      expect(thread).not_to be_valid
      expect(thread.errors[:community]).to be_present
    end
  end

  describe 'アソシエーション' do
    it 'ユーザーに属する' do
      thread = create(:community_thread)
      expect(thread).to respond_to(:user)
    end

    it 'コミュニティに属する' do
      thread = create(:community_thread)
      expect(thread).to respond_to(:community)
    end

    it 'レスを持つ' do
      thread = create(:community_thread)
      expect(thread).to respond_to(:replies)
    end

    it 'スレッドを削除すると関連するレスも削除される' do
      thread = create(:community_thread)
      reply = create(:reply, community_thread: thread)
      
      expect {
        thread.destroy
      }.to change { Reply.count }.by(-1)
    end
  end

  describe 'メソッド' do
    let(:user) { create(:user) }
    let(:community) { create(:community, creator: user) }
    let(:thread) { create(:community_thread, user: user, community: community) }

    it 'レス数を正しく返す' do
      create(:reply, community_thread: thread)
      create(:reply, community_thread: thread)
      expect(thread.replies_count).to eq(2)
    end

    it '所有者の場合、owned_by?はtrueを返す' do
      expect(thread.owned_by?(user)).to be true
    end

    it '非所有者の場合、owned_by?はfalseを返す' do
      other_user = create(:user)
      expect(thread.owned_by?(other_user)).to be false
    end

    it '所有者の場合、can_be_deleted_by?はtrueを返す' do
      expect(thread.can_be_deleted_by?(user)).to be true
    end

    it 'モデレーターの場合、can_be_deleted_by?はtrueを返す' do
      moderator = create(:user)
      create(:community_membership, :moderator, user: moderator, community: community, is_active: true)
      expect(thread.can_be_deleted_by?(moderator)).to be true
    end

    it '一般メンバーの場合、can_be_deleted_by?はfalseを返す' do
      member = create(:user)
      create(:community_membership, user: member, community: community, is_active: true)
      expect(thread.can_be_deleted_by?(member)).to be false
    end
  end
end

