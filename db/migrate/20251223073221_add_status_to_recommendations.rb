class AddStatusToRecommendations < ActiveRecord::Migration[7.0]
  def up
    # statusカラムを追加（デフォルト: pending(0)）
    add_column :recommendations, :status, :integer, null: false, default: 0, comment: "推し付けの状態 (0: pending, 1: favorited, 2: skipped)"
    
    # 既存データの移行: is_skippedがtrueの場合はskipped(2)、falseの場合はfavorited(1)に設定
    # （既に選択済みのデータはfavoritedとして扱う）
    execute <<-SQL
      UPDATE recommendations
      SET status = CASE
        WHEN is_skipped = true THEN 2  -- skipped
        ELSE 1                        -- favorited (既に選択済み)
      END
      WHERE is_skipped IS NOT NULL;
    SQL
    
    # インデックスを追加
    add_index :recommendations, :status, name: "idx_recommendations_status"
  end

  def down
    remove_index :recommendations, name: "idx_recommendations_status"
    remove_column :recommendations, :status
  end
end
