class NewsItem < ActiveRecord::Base
  acts_as_slug
  admin :fields => [:name,:slug,:body,:date,{:kind => {:class => "option'",:choices => ["General News","Press Release"],:label => "Type"}}]#,:reflections => [:news_item_contacts]
  has_many :news_item_contacts
  validates_presence_of :name

  def press_release?
    self.kind == "Press Release"
  end

  def url
    {:controller => "main",:action => self.press_release? ? "press_release" : "news_item",:id => self.slug.blank? ? 'not-found' : self.slug}
  end

  protected
  def after_find
    NewsItem.admin_reflections = self.press_release? ? [:news_item_contacts] : :none
  end
end