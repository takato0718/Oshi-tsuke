class AddUuidToCommunities < ActiveRecord::Migration[7.0]
  def change
    add_column :communities, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_index :communities, :uuid, unique: true
  end
end
