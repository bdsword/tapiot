class ChangeCreatedAtToDefaultTimestampInTaps < ActiveRecord::Migration
  def up
    remove_column :taps, :created_at
    add_timestamps :taps, null: false
  end

  def down
    remove_timestamps :taps
    add_column :taps, :created_at, :timestamp
  end
end
