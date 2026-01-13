require 'rails_helper'

RSpec.describe Recommendation, type: :model do
  describe 'バリデーション' do
    let(:user) { create(:user) }
    let(:post) { create(:post) }

    it 'ユーザーと投稿があれば有効' do
      recommendation = build(:recommendation, user: user, post: post)
      expect(recommendation).to be_valid
    end

    it 'ユーザーIDがなければ無効' do
      recommendation = build(:recommendation, user: nil)
      expect(recommendation).not_to be_valid
      expect(recommendation.errors[:user_id]).to include('を入力してください')
    end

    it '投稿IDがなければ無効' do
      recommendation = build(:recommendation, post: nil)
      expect(recommendation).not_to be_valid
      expect(recommendation.errors[:post_id]).to include('を入力してください')
    end
  end

  describe 'アソシエーション' do
    it 'ユーザーに属する' do
      recommendation = create(:recommendation)
      expect(recommendation).to respond_to(:user)
    end

    it '投稿に属する' do
      recommendation = create(:recommendation)
      expect(recommendation).to respond_to(:post)
    end
  end

  describe 'スコープ' do
    it '今日の推し紹介を返す' do
      today_recommendation = create(:recommendation)
      old_recommendation = create(:recommendation, created_at: 2.days.ago)
      
      expect(Recommendation.today).to include(today_recommendation)
      expect(Recommendation.today).not_to include(old_recommendation)
    end
  end

  describe 'メソッド' do
    let(:recommendation) { create(:recommendation) }

    it 'skip!はステータスをskippedに更新する' do
      recommendation.skip!
      expect(recommendation.skipped?).to be true
      expect(recommendation.skipped_at).not_to be_nil
      expect(recommendation.viewed_at).not_to be_nil
    end

    it 'favorite!はステータスをfavoritedに更新する' do
      recommendation.favorite!
      expect(recommendation.favorited?).to be true
      expect(recommendation.viewed_at).not_to be_nil
    end

    it 'mark_as_viewed!はviewed_atを設定する' do
      recommendation.mark_as_viewed!
      expect(recommendation.viewed_at).not_to be_nil
    end

    it 'mark_as_viewed!は既存のviewed_atを上書きしない' do
      original_viewed_at = 1.day.ago
      recommendation.update!(viewed_at: original_viewed_at)
      recommendation.mark_as_viewed!
      expect(recommendation.viewed_at.to_i).to eq(original_viewed_at.to_i)
    end
  end
end

