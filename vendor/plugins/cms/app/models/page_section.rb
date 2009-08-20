class PageSection < ActiveRecord::Base
  belongs_to :page
  validates_presence_of :page,:section

  def html
    case self.body_filter
    when "textile"
      RedCloth.new(self.body).to_html
    when "markdown"
      BlueCloth.new(self.body).to_html
    when "html","wysiwyg",nil
      self.body
    end
  end

  def name
    CMS.content_areas[self.section.to_sym]
  end
end