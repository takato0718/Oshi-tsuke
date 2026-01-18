class AddOmniauthToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :avatar_url, :string

    # providerとuidの組み合わせにユニークインデックスを追加
    add_index :users, [:provider, :uid], unique: true, name: 'idx_users_provider_uid'
  end
end
