class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.timestamps null: false
      t.string :facebook_id, null: false
      t.string :first_name, null: false
      t.string :image_url, null: false
      t.string :last_name, null: false
    end

    add_index :users, :facebook_id
  end
end
