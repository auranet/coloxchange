class Keyword < ActiveRecord::Base
  has_and_belongs_to_many :clicks
  validates_presence_of :name
end