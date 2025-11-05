class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :bigint do |t|
      t.string :name, null: false, comment: "ユーザーの表示名"
      t.string :email, null: false, comment: "ログイン認証用のメールアドレス"
      t.string :crypted_password, null: false, comment: "ハッシュ化されたパスワード"
      t.string :salt, null: false, comment: "パスワードハッシュ化用のソルト値"
      t.string :profile_image, comment: "プロフィール画像のファイルパス/URL"
      t.string :reset_password_token, comment: "パスワードリセット用の一時トークン"
      t.datetime :reset_password_token_expires_at, comment: "パスワードリセットトークンの有効期限"
      t.datetime :reset_password_email_sent_at, comment: "パスワードリセットメール送信日時"
      t.string :remember_me_token, comment: "ログイン状態を保持機能用のトークン"
      t.datetime :remember_me_token_expires_at, comment: "ログイン保持トークンの有効期限"

      t.timestamps null: false
    end
    # ログイン処理で頻繁に使うため
    add_index :users, :email, unique: true, name: "idx_users_email"
    add_index :users, :reset_password_token, name: "idx_users_reset_password_token"
  end
end
