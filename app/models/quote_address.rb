class QuoteAddress < ActiveRecord::Base
  acts_as_list :scope => :quote_id
  belongs_to :address
  belongs_to :quote
  validates_presence_of :address, :quote
end