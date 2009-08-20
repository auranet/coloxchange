class NameBasedModel < ActiveRecord::Base
  acts_as_slug
  validates_presence_of :name
end