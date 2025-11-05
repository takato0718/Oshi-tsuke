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

ActiveRecord::Schema[7.0].define(version: 2025_11_04_095834) do
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

end
