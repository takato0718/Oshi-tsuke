class CreateCommunityThreads < ActiveRecord::Migration[7.0]
  def change
    create_table :community_threads, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, comment: "投稿者のユーザーID"
      t.references :community, null: false, foreign_key: true, type: :bigint, comment: "投稿先コミュニティのID"
      t.text :description, null: false, comment: "スレッドの本文"
      
      t.timestamps null: false
    end
    
    add_index :community_threads, :user_id, name: "idx_community_threads_user_id"
    add_index :community_threads, :community_id, name: "idx_community_threads_community_id"
    add_index :community_threads, :created_at, name: "idx_community_threads_created_at"
  end
end
