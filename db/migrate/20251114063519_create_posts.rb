class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, comment: "投稿者のユーザーID"
      t.references :community, null: true, foreign_key: false, type: :bigint, comment: "投稿先コミュニティのID（MVPの段階ではNULL）"
      t.string :title, null: false, comment: "投稿のタイトル"
      t.text :description, null: false, comment: "投稿の本文"
      t.string :image, comment: "投稿に添付する画像のファイルパス/URL"
      t.string :youtube_url, limit: 500, comment: "YouTube動画のURL"
      
      t.timestamps null: false
    end
    
    add_index :posts, :user_id, name: "idx_posts_user_id"
    add_index :posts, :created_at, name: "idx_posts_created_at"
  end
end
