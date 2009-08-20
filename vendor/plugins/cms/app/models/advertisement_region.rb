class AdvertisementRegion < ActiveRecord::Base
  admin :maps => true,:name => "Region",:reflections => :none
  has_and_belongs_to_many :advertisements
  validates_presence_of :name,:ne_lat,:ne_lng,:sw_lat,:sw_lng
end