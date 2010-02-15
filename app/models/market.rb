class Market < ActiveRecord::Base
  admin :browse_columns => [:city, :state], :fields => [:city, :state], :order => 'state, city'
  validates_presence_of :city

  def name
    [city, state].reject(&:blank?).join(', ')
  end
end