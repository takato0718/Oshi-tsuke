class ModifyReactionsUniqueConstraint < ActiveRecord::Migration[7.0]
  def up
    # 既存のユニーク制約を削除
    remove_index :reactions, name: "idx_reactions_user_post_type_unique"
    
    # likeタイプのみにユニーク制約を適用する部分インデックス（PostgreSQL）
    add_index :reactions, [:user_id, :post_id], 
              unique: true, 
              where: "reaction_type = 0", # reaction_type = 0 は like
              name: "idx_reactions_user_post_like_unique"
  end

  def down
    # 部分インデックスを削除
    remove_index :reactions, name: "idx_reactions_user_post_like_unique"
    
    # 元のユニーク制約を復元
    add_index :reactions, [:user_id, :post_id, :reaction_type], 
              unique: true, 
              name: "idx_reactions_user_post_type_unique"
  end
end
