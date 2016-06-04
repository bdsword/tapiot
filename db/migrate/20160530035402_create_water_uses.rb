class CreateWaterUses < ActiveRecord::Migration
  def change
    create_table :water_uses do |t|
      t.integer :tap_id
      t.integer :user_id
      t.float :water_consumed

      t.timestamps null: false
    end
  end
end
