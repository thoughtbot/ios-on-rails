class AddLocationFieldsToEvents < ActiveRecord::Migration
  def up
    add_column :events, :address, :string
    add_column :events, :lat, :float, null: false
    add_column :events, :lon, :float, null: false
    remove_column :events, :place_id
  end

  def down
    remove_column :events, :address
    remove_column :events, :lat
    remove_column :events, :lon
    add_column :events, :place_id, :integer, null: false
  end
end
