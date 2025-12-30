class MigratePostsToThreadsAndReplies < ActiveRecord::Migration[7.0]
  def up
    # スレッド投稿を移行（community_idが存在し、parent_idがnilのもの）
    execute <<-SQL
      INSERT INTO community_threads (id, user_id, community_id, description, created_at, updated_at)
      SELECT id, user_id, community_id, description, created_at, updated_at
      FROM posts
      WHERE community_id IS NOT NULL AND parent_id IS NULL;
    SQL

    # レス投稿を移行（parent_idが存在するもの）
    # 親投稿のIDをcommunity_thread_idとして使用
    execute <<-SQL
      INSERT INTO replies (id, user_id, community_thread_id, description, created_at, updated_at)
      SELECT 
        p.id,
        p.user_id,
        p.parent_id AS community_thread_id,
        p.description,
        p.created_at,
        p.updated_at
      FROM posts p
      WHERE p.parent_id IS NOT NULL;
    SQL
  end

  def down
    # ロールバック処理
    execute <<-SQL
      DELETE FROM replies;
      DELETE FROM community_threads;
    SQL
  end
end
