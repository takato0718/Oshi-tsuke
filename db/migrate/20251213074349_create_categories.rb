class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories, id: :bigint do |t|
      t.string :name, null: false, comment: "カテゴリ名"
      t.string :description, comment: "カテゴリの説明"
      t.timestamps null: false
    end
    add_index :categories, :name, unique: true, name: "idx_categories_name"
  end
end
