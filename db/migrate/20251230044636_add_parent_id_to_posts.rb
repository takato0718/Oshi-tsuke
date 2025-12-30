class AddParentIdToPosts < ActiveRecord::Migration[7.0]
  def change
    add_reference :posts, :parent, null: true, foreign_key: { to_table: :posts }, type: :bigint, comment: "親投稿ID（スレッド機能用）"
    add_index :posts, :parent_id, name: "idx_posts_parent_id"
  end
end
