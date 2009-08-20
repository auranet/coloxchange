class SnippetAttachment < ActiveRecord::Base
  admin :order => "snippet_attachments.snippet_id"
  belongs_to :page
  belongs_to :snippet
  validates_presence_of :page, :if => :use_page?
  validates_presence_of :snippet

  def area
    self.attributes["position"] || self.attributes["area"]
  end

  def controller
    "#{self.attributes["controller"]}/#{self.action}"
  end

  def name
    "#{self.snippet.name} (#{self.page ? self.page.name.shorten(20) : "#{self.attributes["controller"].humanize}: #{self.action == "index" ? "Home" : self.action.humanize}"} / #{CMS.snippet_positions[self.position.to_sym]})"
  rescue
    "Broken attachment!"
  end

  protected
  def before_save
    case self.attach_to
    when "page"
    when "action"
      split = self.attributes["controller"].split("/")
      self.controller = split[0]
      self.action = split[1]
      self.page_id = nil
    else
      @errors.add_to_base("You must select one of page, action, or URL for \"points to.\"")
    end
  end

  private
  def use_page?
    return self.attach_to == "page"
  end
end