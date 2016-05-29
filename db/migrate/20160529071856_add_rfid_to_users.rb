class AddRfidToUsers < ActiveRecord::Migration
  def up
    add_column :users, :rfid, :integer
  end

  def down
    remove_column :users, :rfid
  end
end
