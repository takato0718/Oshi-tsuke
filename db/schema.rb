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

ActiveRecord::Schema[7.0].define(version: 2025_12_13_074742) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false, comment: "カテゴリ名"
    t.string "description", comment: "カテゴリの説明"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_categories_name", unique: true
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
    t.bigint "community_id", comment: "投稿先コミュニティのID（MVPの段階ではNULL）"
    t.string "title", null: false, comment: "投稿のタイトル"
    t.text "description", null: false, comment: "投稿の本文"
    t.string "image", comment: "投稿に添付する画像のファイルパス/URL"
    t.string "youtube_url", limit: 500, comment: "YouTube動画のURL"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_posts_on_community_id"
    t.index ["created_at"], name: "idx_posts_created_at"
    t.index ["user_id"], name: "idx_posts_user_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "recommendations", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "レコメンド対象のユーザーID"
    t.bigint "post_id", null: false, comment: "レコメンドする投稿のID"
    t.boolean "is_skipped", default: false, null: false, comment: "ユーザーがレコメンドをスキップしたかの判定"
    t.datetime "viewed_at", comment: "ユーザーがレコメンドを閲覧した日時"
    t.datetime "skipped_at", comment: "ユーザーがレコメンドをスキップした日時"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "idx_recommendations_post"
    t.index ["post_id"], name: "index_recommendations_on_post_id"
    t.index ["user_id", "created_at"], name: "idx_recommendations_user_date"
    t.index ["user_id", "is_skipped"], name: "idx_recommendations_user_skipped"
    t.index ["user_id"], name: "index_recommendations_on_user_id"
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

  add_foreign_key "post_categories", "categories"
  add_foreign_key "post_categories", "posts"
  add_foreign_key "posts", "users"
  add_foreign_key "recommendations", "posts"
  add_foreign_key "recommendations", "users"
end
