class PopulateUuidForExistingRecords < ActiveRecord::Migration[7.0]
  def up
    # 既存のPostレコードにUUIDを付与
    Post.where(uuid: nil).find_each do |post|
      post.update_column(:uuid, SecureRandom.uuid)
    end

    # 既存のCommunityレコードにUUIDを付与
    Community.where(uuid: nil).find_each do |community|
      community.update_column(:uuid, SecureRandom.uuid)
    end
  end

  def down
    # ロールバック時は何もしない（UUIDカラムは残す）
  end
end
