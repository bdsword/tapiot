class WaterUse < ActiveRecord::Base
  belongs_to :user
  belongs_to :tap
end
