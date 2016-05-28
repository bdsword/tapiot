class CreateTap < ActiveRecord::Migration
  def change
    create_table :taps do |t|
      t.string :location
      t.timestamp :created_at
    end
  end
end
