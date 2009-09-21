class Page < ActiveRecord::Base
  acts_as_list
  acts_as_slug :message => "URL has been taken"
  acts_as_tree :counter_cache => true,:order => "pages.position ASC"
  admin :browse_columns => [:name,{:admin_url => "URL"}],:filters => [:name],:order => "LOWER(REPLACE(pages.slug,'/','')) ASC",:reflections => [:snippets]
  attr_accessor :page_section_hashes,:section_cache
  belongs_to :user
  has_many :active_children,:class_name => "Page",:conditions => ["pages.active = ?",true],:foreign_key => "parent_id",:order => ["pages.position ASC"]
  has_many :menu_items
  has_many :page_sections,:dependent => :destroy
  has_many :snippet_attachments
  has_many :snippets, :through => :snippet_attachments
  validates_presence_of :name,:message => "Title cannot be blank"

  def admin_url
    "#{domain_short}#{self.attached? && self.slug == "homepage" ? "" : self.url}"
  end

  def auto_menu?
    [self,self.ancestors].flatten.collect{|page| page.menu_items}.flatten.any?{|menu_item| menu_item.auto_update}
  end

  def cached?
    !self.attached? && File.exists?(File.join(RAILS_ROOT,"public","#{self.url[1,self.url.length-1]}.html"))
  end

  def children_tree(depth,remove = nil,urls = false)
    pages = []
    self.children.find(:all,:include => [:children]).each do |child|
      pages.push(["#{"· "*depth} #{child.name}",urls ? child.url : child.id])
      child.children_tree(depth.next,remove,urls).each{|child2| pages.push(child2)}
    end
    pages
  end

  def list
    if self.parent_id
      self.parent.list
    else
      [self,self.children].flatten.select{|page| page.active}
    end
  end

  def html
    case self.body_filter
    when "textile"
      RedCloth.new(self.body).to_html
    when "markdown"
      BlueCloth.new(self.body).to_html
    when "html","wysiwyg","",nil
      self.body
    end if self.body
  end

  def section(section)
    return self.section_cache[section] if self.section_cache
    self.section_cache = {}
    for page_section in self.page_sections
      self.section_cache[page_section.section.to_sym] = page_section.html
    end
    self.section_cache[section]
  end

  def self_and_active_siblings
    self.self_and_siblings.select{|page| page.active}
  end

  def self_and_ancestors
    [self, self.ancestors].flatten
  end

  def suppress_title?
    self.attributes["suppress_title"]
  end

  def tree
    pages = []
    depth = 1
    (Page.find(:all,:conditions => ["pages.parent_id IS NULL"],:order => "pages.position",:include => [:children]) - [self]).each do |page|
      pages.push([page.name,page.id])
      page.children_tree(depth,self).each{|child| pages.push(child)}
    end
    pages
  end

  def url
    case self.attached?
    when true
      self.slug
    else
      "/#{self.self_and_ancestors.reverse.flatten.collect{|page| page.slug.split("/").without("").join("/")}.join("/")}"
    end
  end

  def self.tree(urls = false,conditions = [])
    pages = []
    depth = 1
    if conditions.empty?
      conditions[0] = "pages.parent_id IS NULL"
    else
      conditions[0] << " AND pages.parent_id IS NULL"
    end
    self.find(:all,:conditions => conditions,:order => "pages.name ASC",:include => [:children]).each do |page|
      pages.push([page.name,urls ? page.url : page.id])
      page.children_tree(depth,nil,urls).each{|child| pages.push(child)}
    end
    pages
  end

  protected
  def after_save
    if self.auto_menu?
      for menu_item in [self,self.ancestors].flatten.collect{|page| page.menu_items}.flatten.select{|menu_item| menu_item.auto_update}
        menu_item.save
      end
    end
    CMS.page_urls[self.controller.to_sym][self.action.to_sym] = true if self.attached && self.controller && self.action
  end

  def before_destroy
    self.menu_items.destroy_all
  end

  def before_save
    self.page_sections.destroy_all
    for section,hash in self.page_section_hashes
      page_section = (self.page_sections.select{|page_section| page_section.id.to_s == hash["id"]}[0] || self.page_sections.build)
      page_section.update_attributes(hash.update({:section => section}))
      self.page_sections << page_section
    end if self.page_section_hashes
  end
end