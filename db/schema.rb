# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_01_08_133145) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false, comment: "カテゴリ名"
    t.string "description", comment: "カテゴリの説明"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_categories_name", unique: true
  end

  create_table "communities", force: :cascade do |t|
    t.string "name", null: false, comment: "コミュニティ名"
    t.text "description", comment: "コミュニティの説明"
    t.bigint "creator_id", null: false, comment: "コミュニティ作成者のユーザーID"
    t.boolean "is_public", default: true, null: false, comment: "公開設定（true: 公開, false: 非公開）"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "idx_communities_creator"
    t.index ["creator_id"], name: "index_communities_on_creator_id"
    t.index ["is_public"], name: "idx_communities_is_public"
    t.index ["name"], name: "idx_communities_name_unique", unique: true
  end

  create_table "community_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "参加ユーザーID"
    t.bigint "community_id", null: false, comment: "参加コミュニティID"
    t.integer "role", default: 0, null: false, comment: "権限レベル (0: member, 1: moderator, 2: admin)"
    t.datetime "joined_at", comment: "参加日時"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true, null: false, comment: "参加状態の有効性フラグ（承認制の場合に使用）"
    t.index ["community_id", "role"], name: "idx_community_memberships_community_role"
    t.index ["community_id"], name: "idx_community_memberships_community"
    t.index ["community_id"], name: "index_community_memberships_on_community_id"
    t.index ["is_active"], name: "idx_community_memberships_is_active"
    t.index ["user_id", "community_id"], name: "idx_community_memberships_user_community_unique", unique: true
    t.index ["user_id"], name: "idx_community_memberships_user"
    t.index ["user_id"], name: "index_community_memberships_on_user_id"
  end

  create_table "community_threads", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "投稿者のユーザーID"
    t.bigint "community_id", null: false, comment: "投稿先コミュニティのID"
    t.text "description", null: false, comment: "スレッドの本文"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "idx_community_threads_community_id"
    t.index ["community_id"], name: "index_community_threads_on_community_id"
    t.index ["created_at"], name: "idx_community_threads_created_at"
    t.index ["user_id"], name: "idx_community_threads_user_id"
    t.index ["user_id"], name: "index_community_threads_on_user_id"
  end

  create_table "post_categories", force: :cascade do |t|
    t.bigint "post_id", null: false, comment: "投稿ID"
    t.bigint "category_id", null: false, comment: "カテゴリID"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "idx_post_categories_category"
    t.index ["category_id"], name: "index_post_categories_on_category_id"
    t.index ["post_id", "category_id"], name: "idx_post_categories_unique", unique: true
    t.index ["post_id"], name: "index_post_categories_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "投稿者のユーザーID"
    t.string "title", null: false, comment: "投稿のタイトル"
    t.text "description", null: false, comment: "投稿の本文"
    t.string "image", comment: "投稿に添付する画像のファイルパス/URL"
    t.string "youtube_url", limit: 500, comment: "YouTube動画のURL"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "idx_posts_created_at"
    t.index ["user_id"], name: "idx_posts_user_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "リアクションしたユーザーID"
    t.bigint "post_id", null: false, comment: "リアクション対象の投稿ID"
    t.integer "reaction_type", null: false, comment: "リアクションの種類（0: いいね, 1: コメント）"
    t.text "content", comment: "コメント内容（reaction_typeがコメントの場合のみ使用）"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "reaction_type"], name: "idx_reactions_post_type"
    t.index ["post_id"], name: "idx_reactions_post"
    t.index ["post_id"], name: "index_reactions_on_post_id"
    t.index ["user_id", "post_id"], name: "idx_reactions_user_post_like_unique", unique: true, where: "(reaction_type = 0)"
    t.index ["user_id"], name: "idx_reactions_user"
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "recommendations", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "レコメンド対象のユーザーID"
    t.bigint "post_id", null: false, comment: "レコメンドする投稿のID"
    t.boolean "is_skipped", default: false, null: false, comment: "ユーザーがレコメンドをスキップしたかの判定"
    t.datetime "viewed_at", comment: "ユーザーがレコメンドを閲覧した日時"
    t.datetime "skipped_at", comment: "ユーザーがレコメンドをスキップした日時"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false, comment: "推し付けの状態 (0: pending, 1: favorited, 2: skipped)"
    t.index ["post_id"], name: "idx_recommendations_post"
    t.index ["post_id"], name: "index_recommendations_on_post_id"
    t.index ["status"], name: "idx_recommendations_status"
    t.index ["user_id", "created_at"], name: "idx_recommendations_user_date"
    t.index ["user_id", "is_skipped"], name: "idx_recommendations_user_skipped"
    t.index ["user_id"], name: "index_recommendations_on_user_id"
  end

  create_table "replies", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "投稿者のユーザーID"
    t.bigint "community_thread_id", null: false, comment: "スレッドID"
    t.text "description", null: false, comment: "レス投稿の本文"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_thread_id"], name: "idx_replies_thread_id"
    t.index ["community_thread_id"], name: "index_replies_on_community_thread_id"
    t.index ["created_at"], name: "idx_replies_created_at"
    t.index ["user_id"], name: "idx_replies_user_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "報告者のユーザーID"
    t.string "reportable_type", null: false
    t.bigint "reportable_id", null: false, comment: "報告対象（Post, CommunityThread, Reply, Reaction）"
    t.text "reason", null: false, comment: "報告理由"
    t.integer "status", default: 0, null: false, comment: "報告の状態 (0: pending, 1: reviewed, 2: resolved, 3: dismissed)"
    t.bigint "reviewed_by_id", comment: "レビューしたユーザーID（モデレーターまたは管理者）"
    t.text "review_notes", comment: "レビュー時のメモ"
    t.datetime "reviewed_at", comment: "レビュー日時"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reportable_type", "reportable_id"], name: "idx_reports_reportable"
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable"
    t.index ["reviewed_by_id"], name: "idx_reports_reviewed_by"
    t.index ["status"], name: "idx_reports_status"
    t.index ["user_id"], name: "idx_reports_user_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false, comment: "ユーザーの表示名"
    t.string "email", null: false, comment: "ログイン認証用のメールアドレス"
    t.string "crypted_password", null: false, comment: "ハッシュ化されたパスワード"
    t.string "salt", null: false, comment: "パスワードハッシュ化用のソルト値"
    t.string "profile_image", comment: "プロフィール画像のファイルパス/URL"
    t.string "reset_password_token", comment: "パスワードリセット用の一時トークン"
    t.datetime "reset_password_token_expires_at", comment: "パスワードリセットトークンの有効期限"
    t.datetime "reset_password_email_sent_at", comment: "パスワードリセットメール送信日時"
    t.string "remember_me_token", comment: "ログイン状態を保持機能用のトークン"
    t.datetime "remember_me_token_expires_at", comment: "ログイン保持トークンの有効期限"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "idx_users_email", unique: true
    t.index ["reset_password_token"], name: "idx_users_reset_password_token"
  end

  add_foreign_key "communities", "users", column: "creator_id"
  add_foreign_key "community_memberships", "communities"
  add_foreign_key "community_memberships", "users"
  add_foreign_key "community_threads", "communities"
  add_foreign_key "community_threads", "users"
  add_foreign_key "post_categories", "categories"
  add_foreign_key "post_categories", "posts"
  add_foreign_key "posts", "users"
  add_foreign_key "reactions", "posts"
  add_foreign_key "reactions", "users"
  add_foreign_key "recommendations", "posts"
  add_foreign_key "recommendations", "users"
  add_foreign_key "replies", "community_threads"
  add_foreign_key "replies", "users"
  add_foreign_key "reports", "users"
  add_foreign_key "reports", "users", column: "reviewed_by_id"
end
