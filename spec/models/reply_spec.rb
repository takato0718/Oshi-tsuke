require 'rails_helper'

RSpec.describe Reply, type: :model do
  describe 'バリデーション' do
    it '説明、ユーザー、スレッドがあれば有効' do
      reply = build(:reply)
      expect(reply).to be_valid
    end

    it '説明がなければ無効' do
      reply = build(:reply, description: nil)
      expect(reply).not_to be_valid
      expect(reply.errors[:description]).to include('を入力してください')
    end

    it 'ユーザーIDがなければ無効' do
      reply = build(:reply, user: nil)
      expect(reply).not_to be_valid
      expect(reply.errors[:user]).to be_present
    end

    it 'スレッドIDがなければ無効' do
      reply = build(:reply, community_thread: nil)
      expect(reply).not_to be_valid
      expect(reply.errors[:community_thread]).to be_present
    end
  end

  describe 'アソシエーション' do
    it 'ユーザーに属する' do
      reply = create(:reply)
      expect(reply).to respond_to(:user)
    end

    it 'スレッドに属する' do
      reply = create(:reply)
      expect(reply).to respond_to(:community_thread)
    end

    it 'コミュニティを正しく返す' do
      reply = create(:reply)
      expect(reply.community).to eq(reply.community_thread.community)
    end
  end

  describe 'メソッド' do
    let(:user) { create(:user) }
    let(:community) { create(:community, creator: user) }
    let(:thread) { create(:community_thread, user: user, community: community) }
    let(:reply) { create(:reply, user: user, community_thread: thread) }

    it '所有者の場合、owned_by?はtrueを返す' do
      expect(reply.owned_by?(user)).to be true
    end

    it '非所有者の場合、owned_by?はfalseを返す' do
      other_user = create(:user)
      expect(reply.owned_by?(other_user)).to be false
    end

    it '所有者の場合、can_be_deleted_by?はtrueを返す' do
      expect(reply.can_be_deleted_by?(user)).to be true
    end

    it 'モデレーターの場合、can_be_deleted_by?はtrueを返す' do
      moderator = create(:user)
      create(:community_membership, :moderator, user: moderator, community: community, is_active: true)
      expect(reply.can_be_deleted_by?(moderator)).to be true
    end

    it '一般メンバーの場合、can_be_deleted_by?はfalseを返す' do
      member = create(:user)
      create(:community_membership, user: member, community: community, is_active: true)
      expect(reply.can_be_deleted_by?(member)).to be false
    end
  end
end

