class Snippet < ActiveRecord::Base
  admin :fields => [:name,{:body => {:class => "editor"}}],:reflections => [:snippet_attachments]
  has_many :snippet_attachments,:dependent => :destroy
  validates_presence_of :name,:body

  def self.position_name(position_integer)
    CMS.snippet_positions.select{|key,value| value == position_integer}[0][0].to_s.humanize
  end

  def self.positions
    [CMS.snippet_positions.values,CMS.snippet_positions.keys].transpose
  end
end