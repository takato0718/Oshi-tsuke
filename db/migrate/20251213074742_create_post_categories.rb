class CreatePostCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :post_categories, id: :bigint do |t|
      t.references :post, null: false, foreign_key: true, type: :bigint, comment: "投稿ID"
      t.references :category, null: false, foreign_key: true, type: :bigint, comment: "カテゴリID"
      t.timestamps null: false
    end
    add_index :post_categories, [:post_id, :category_id], unique: true, name: "idx_post_categories_unique"
    add_index :post_categories, :category_id, name: "idx_post_categories_category" ## カテゴリーIDのみのインデックスもつける
  end
end
