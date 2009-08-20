class MenuItem < ActiveRecord::Base
  attr_accessor :auto_build
  acts_as_list :scope => :menu_id
  acts_as_tree :counter_cache => true,:order => "menu_items.position ASC" if CMS.hierarchical_menus
  admin :reflections => :none
  belongs_to :menu
  belongs_to :page
  validates_inclusion_of :point_to, :in => ["action","page","url"]
  validates_presence_of :name,:message => "Label can't be blank"
  validates_presence_of :point_to

  def auto_update?(include_self = true)
    CMS.hierarchical_menus && [(include_self ? self : nil),self.ancestors].flatten.compact.any?{|menu_item| menu_item.auto_update}
  end

  def build_hierarchy
    if self.point_to == "page" && self.page
      self.children.destroy_all
      for page in self.page.active_children
        self.children << MenuItem.create(:name => page.name,:point_to => "page",:page_id => page.id,:auto_build => true,:auto_update => false)
      end
    end
  end

  def controller
    "#{self.attributes["controller"]}/#{self.action}"
  end

  def full_url
    case self.point_to
    when "page"
      self.page.url
    when "action"
      {:controller => self.attributes["controller"],:action => self.action,:id => self.id_}
    when "url"
      self.url
    end
  end

  protected
  def after_update
    self.build_hierarchy if self.auto_update
  end

  def before_save
    self.url = "http://#{self.url}" if self.point_to == "url" && !self.url.include?(/http(s)*:\/\//)
  end
end