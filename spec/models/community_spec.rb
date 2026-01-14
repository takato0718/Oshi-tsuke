require 'rails_helper'

RSpec.describe Community, type: :model do
  describe 'バリデーション' do
    it '名前、作成者、公開設定があれば有効' do
      creator = create(:user)
      community = build(:community, creator: creator)
      expect(community).to be_valid
    end

    it '名前がなければ無効' do
      community = build(:community, name: nil)
      expect(community).not_to be_valid
      expect(community.errors[:name]).to include('を入力してください')
    end

    it '名前が一意でなければ無効' do
      create(:community, name: 'Test Community')
      community = build(:community, name: 'Test Community')
      expect(community).not_to be_valid
      expect(community.errors[:name]).to be_present
    end

    it '名前が100文字を超えると無効' do
      community = build(:community, name: 'a' * 101)
      expect(community).not_to be_valid
      expect(community.errors[:name]).to include('は100文字以内で入力してください')
    end

    it '説明が1000文字を超えると無効' do
      community = build(:community, description: 'a' * 1001)
      expect(community).not_to be_valid
      expect(community.errors[:description]).to include('は1000文字以内で入力してください')
    end

    it '作成者IDがなければ無効' do
      community = build(:community, creator_id: nil)
      expect(community).not_to be_valid
      expect(community.errors[:creator_id]).to include('を入力してください')
    end

    it '公開設定がbooleanでなければ無効' do
      community = build(:community, is_public: nil)
      expect(community).not_to be_valid
      expect(community.errors[:is_public]).to include('は一覧にありません')
    end
  end

  describe 'アソシエーション' do
    it '作成者に属する' do
      community = create(:community)
      expect(community).to respond_to(:creator)
    end

    it 'メンバーシップを持つ' do
      community = create(:community)
      expect(community).to respond_to(:community_memberships)
    end

    it 'メンバーを持つ' do
      community = create(:community)
      expect(community).to respond_to(:members)
    end

    it 'スレッドを持つ' do
      community = create(:community)
      expect(community).to respond_to(:community_threads)
    end

    it 'レスを持つ' do
      community = create(:community)
      expect(community).to respond_to(:replies)
    end
  end

  describe 'メソッド' do
    let(:user) { create(:user) }
    let(:community) { create(:community, creator: user) }

    it '公開コミュニティの場合、public?はtrueを返す' do
      expect(community.public?).to be true
    end

    it '非公開コミュニティの場合、public?はfalseを返す' do
      private_community = create(:community, :private, creator: user)
      expect(private_community.public?).to be false
    end

    it 'アクティブなメンバーの場合、member?はtrueを返す' do
      member = create(:user)
      create(:community_membership, user: member, community: community, is_active: true)
      expect(community.member?(member)).to be true
    end

    it '非メンバーの場合、member?はfalseを返す' do
      non_member = create(:user)
      expect(community.member?(non_member)).to be false
    end

    it '管理者の場合、can_moderate?はtrueを返す' do
      admin = create(:user)
      create(:community_membership, :admin, user: admin, community: community, is_active: true)
      expect(community.can_moderate?(admin)).to be true
    end

    it '作成者の場合、can_moderate?はtrueを返す' do
      expect(community.can_moderate?(user)).to be true
    end

    it 'スレッド数を正しく返す' do
      create(:community_thread, community: community)
      expect(community.threads_count).to eq(1)
    end

    it 'レス数を正しく返す' do
      thread = create(:community_thread, community: community)
      create(:reply, community_thread: thread)
      expect(community.replies_count).to eq(1)
    end

    it '活発度スコアを正しく計算する' do
      thread = create(:community_thread, community: community)
      create(:reply, community_thread: thread)
      # activity_score = threads_count * 2 + replies_count = 1 * 2 + 1 = 3
      expect(community.activity_score).to eq(3)
    end
  end
end
