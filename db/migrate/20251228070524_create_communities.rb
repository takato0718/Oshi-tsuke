class CreateCommunities < ActiveRecord::Migration[7.0]
  def change
    create_table :communities, id: :bigint do |t|
      t.string :name, null: false, comment: "コミュニティ名"
      t.text :description, comment: "コミュニティの説明"
      t.references :creator, null: false, foreign_key: { to_table: :users }, type: :bigint, comment: "コミュニティ作成者のユーザーID"
      t.boolean :is_public, null: false, default: true, comment: "公開設定（true: 公開, false: 非公開）"
      
      t.timestamps null: false
    end
    
    # コミュニティ名のユニーク制約
    add_index :communities, :name, unique: true, name: "idx_communities_name_unique"
    # 作成者IDのインデックス
    add_index :communities, :creator_id, name: "idx_communities_creator"
    # 公開設定のインデックス
    add_index :communities, :is_public, name: "idx_communities_is_public"
  end
end
