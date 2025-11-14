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

ActiveRecord::Schema[7.0].define(version: 2025_11_14_063519) do
  create_table "posts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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

  add_foreign_key "posts", "users"
end
