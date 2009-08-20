class QuoteDataCenter < ActiveRecord::Base
  belongs_to :quote
  validates_presence_of :data_center_slug, :quote
end