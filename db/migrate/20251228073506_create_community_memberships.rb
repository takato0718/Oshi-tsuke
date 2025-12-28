class CreateCommunityMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :community_memberships, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, comment: "参加ユーザーID"
      t.references :community, null: false, foreign_key: true, type: :bigint, comment: "参加コミュニティID"
      t.integer :role, null: false, default: 0, comment: "権限レベル (0: member, 1: moderator, 2: admin)"
      t.datetime :joined_at, comment: "参加日時"
      
      t.timestamps null: false
    end
    
    # ユニーク制約：同一ユーザーが同一コミュニティに重複参加できない
    add_index :community_memberships, [:user_id, :community_id], 
              unique: true, 
              name: "idx_community_memberships_user_community_unique"
    # コミュニティごとのメンバー取得用インデックス
    add_index :community_memberships, :community_id, name: "idx_community_memberships_community"
    # ユーザーごとの参加コミュニティ取得用インデックス
    add_index :community_memberships, :user_id, name: "idx_community_memberships_user"
    # 権限レベルでの検索用インデックス
    add_index :community_memberships, [:community_id, :role], name: "idx_community_memberships_community_role"
  end
end
