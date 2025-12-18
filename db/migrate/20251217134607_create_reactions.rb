class CreateReactions < ActiveRecord::Migration[7.0]
  def change
    create_table :reactions, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, comment: "リアクションしたユーザーID"
      t.references :post, null: false, foreign_key: true, type: :bigint, comment: "リアクション対象の投稿ID"
      t.integer :reaction_type, null: false, comment: "リアクションの種類（0: いいね, 1: コメント）"
      t.text :content, comment: "コメント内容（reaction_typeがコメントの場合のみ使用）"
      t.timestamps null: false
    end
    # ユニーク制約：同一ユーザーが同一投稿に同じ種類のリアクションを複数回できない
    add_index :reactions, [:user_id, :post_id, :reaction_type], 
              unique: true, 
              name: "idx_reactions_user_post_type_unique"

    # パフォーマンス向上のためのインデックス
    add_index :reactions, :post_id, name: "idx_reactions_post"
    add_index :reactions, :user_id, name: "idx_reactions_user"
    add_index :reactions, [:post_id, :reaction_type], name: "idx_reactions_post_type"
  end
end
