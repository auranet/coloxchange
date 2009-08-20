class NewsletterArticle < ActiveRecord::Base
  acts_as_list :scope => :newsletter_id
  admin :browse_columns => [{:name_with_photo => "Article"},:alignment],:fields => [:newsletter,:article,:photo,{:align => {:choices => [["Left","left"],["Right","right"]]}}],:name => "Article"
  belongs_to :article,:include => [:user]
  belongs_to :newsletter
  belongs_to :photo
  validates_presence_of :article,:newsletter,:photo

  def alignment
    self.align.titleize
  end

  def default_photo
    (self.photo || Photo.new(:url => "/images/none/article.gif"))
  end

  def embed
    self.article.preview && !self.article.preview.blank? ? self.article.preview : self.article.body
  end

  def name
    self.article.name
  end

  def name_with_photo
    "#{self.default_photo.embed(:admin_thumb)} #{self.name}"
  end
end