class AddIsActiveToCommunityMemberships < ActiveRecord::Migration[7.0]
  def change
    add_column :community_memberships, :is_active, :boolean, null: false, default: true, comment: "参加状態の有効性フラグ（承認制の場合に使用）"
    add_index :community_memberships, :is_active, name: "idx_community_memberships_is_active"
  end
end
