class ChangeUserFields < ActiveRecord::Migration
  def up
    add_column :users, :auth_token, :string
    remove_column :users, :facebook_id, :string
    remove_column :users, :first_name, :string
    remove_column :users, :image_url, :string
    remove_column :users, :last_name, :string
    add_index :users, :auth_token, unique: true
  end

  def down
    remove_column :users, :auth_token, :string
    add_column :users, :facebook_id, :string, null: false
    add_column :users, :first_name, :string, null: false
    add_column :users, :image_url, :string, null: false
    add_column :users, :last_name, :string, null: false
  end
end
