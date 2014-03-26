class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.timestamps null: false
      t.integer :event_id, null: false
      t.integer :user_id, null: false
    end

    add_index :attendances, [:event_id, :user_id], unique: true
  end
end
