class CreateReplies < ActiveRecord::Migration[7.0]
  def change
    create_table :replies, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, comment: "投稿者のユーザーID"
      t.references :community_thread, null: false, foreign_key: true, type: :bigint, comment: "スレッドID"
      t.text :description, null: false, comment: "レス投稿の本文"
      
      t.timestamps null: false
    end
    
    add_index :replies, :user_id, name: "idx_replies_user_id"
    add_index :replies, :community_thread_id, name: "idx_replies_thread_id"
    add_index :replies, :created_at, name: "idx_replies_created_at"
  end
end
