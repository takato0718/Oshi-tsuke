class CreateRecommendations < ActiveRecord::Migration[7.0]
  def change
    create_table :recommendations, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, comment: "レコメンド対象のユーザーID"
      t.references :post, null: false, foreign_key: true, type: :bigint, comment: "レコメンドする投稿のID"
      t.boolean :is_skipped, null: false, default: false, comment: "ユーザーがレコメンドをスキップしたかの判定"
      t.datetime :viewed_at, comment: "ユーザーがレコメンドを閲覧した日時"
      t.datetime :skipped_at, comment: "ユーザーがレコメンドをスキップした日時"
      
      t.timestamps null: false
    end

    add_index :recommendations, [:user_id, :created_at], name: "idx_recommendations_user_date"
    add_index :recommendations, :post_id, name: "idx_recommendations_post"
    add_index :recommendations, [:user_id, :is_skipped], name: "idx_recommendations_user_skipped"
  end
end
