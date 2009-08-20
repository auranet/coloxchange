class Company < ActiveRecord::Base
  has_many :contacts, :dependent => :nullify
  validates_presence_of :name
end