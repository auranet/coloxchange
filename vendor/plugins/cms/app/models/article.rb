class Article < ActiveRecord::Base
  acts_as_slug
  belongs_to :photo
  belongs_to :user
  has_and_belongs_to_many :categories,:association_foreign_key => "category_id",:foreign_key => "article_id"
  validates_presence_of :name, :message => "Title cannot be blank"

  def cached?
    File.exists?(File.join(RAILS_ROOT,"public",Base.urls["cms_articles"],"#{self.slug}.html"))
  end

  def failsafe_photo
    self.photo || Photo.new(:url => "/images/article-no-photo.gif")
  end

  def url
    {:controller => "main",:action => "article",:id => self.slug}
  end

  # protected
  # def before_save
  #   if self.body && (!self.preview || self.preview.blank?)
  #     self.preview = self.body.paragraphize(1)
  #   end
  # end
end