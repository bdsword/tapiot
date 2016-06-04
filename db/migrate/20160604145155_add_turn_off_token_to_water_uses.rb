class AddTurnOffTokenToWaterUses < ActiveRecord::Migration
  def change
    add_column :water_uses, :turn_off_token,:string
  end
end
