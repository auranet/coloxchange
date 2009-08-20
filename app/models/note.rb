class Note < ActiveRecord::Base
  belongs_to :contact
  belongs_to :user
  validates_presence_of :body
end