class RemoveCommunityAndParentFromPosts < ActiveRecord::Migration[7.0]
  def change
    # 外部キー制約を削除
    remove_foreign_key :posts, :posts if foreign_key_exists?(:posts, :posts, column: :parent_id)
    remove_foreign_key :posts, :communities if foreign_key_exists?(:posts, :communities)
    
    # インデックスを削除
    remove_index :posts, name: "idx_posts_parent_id" if index_exists?(:posts, :parent_id)
    remove_index :posts, name: "index_posts_on_parent_id" if index_exists?(:posts, :parent_id)
    remove_index :posts, name: "index_posts_on_community_id" if index_exists?(:posts, :community_id)
    
    # カラムを削除
    remove_column :posts, :parent_id, :bigint if column_exists?(:posts, :parent_id)
    remove_column :posts, :community_id, :bigint if column_exists?(:posts, :community_id)
  end
end
