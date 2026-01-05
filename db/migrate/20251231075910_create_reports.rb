class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, comment: "報告者のユーザーID"
      t.references :reportable, null: false, polymorphic: true, type: :bigint, comment: "報告対象（Post, CommunityThread, Reply, Reaction）"
      t.text :reason, null: false, comment: "報告理由"
      t.integer :status, null: false, default: 0, comment: "報告の状態 (0: pending, 1: reviewed, 2: resolved, 3: dismissed)"
      t.bigint :reviewed_by_id, comment: "レビューしたユーザーID（モデレーターまたは管理者）"
      t.text :review_notes, comment: "レビュー時のメモ"
      t.datetime :reviewed_at, comment: "レビュー日時"
      
      t.timestamps null: false
    end
    
    add_index :reports, :user_id, name: "idx_reports_user_id"
    add_index :reports, [:reportable_type, :reportable_id], name: "idx_reports_reportable"
    add_index :reports, :status, name: "idx_reports_status"
    add_index :reports, :reviewed_by_id, name: "idx_reports_reviewed_by"
    add_foreign_key :reports, :users, column: :reviewed_by_id
  end
end
