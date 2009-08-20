class Category < NameBasedModel
  admin :fields => [:name,:slug],:importable => true,:reflections => :none
  validates_uniqueness_of :name
  if Rails.plugins[:blog]
    has_and_belongs_to_many :blog_posts
  end
  if Rails.plugins[:cms]
    has_and_belongs_to_many :articles
  end
  if Rails.plugins[:faq]
    has_and_belongs_to_many :frequently_asked_questions
  end
  if Rails.plugins[:store]
    has_and_belongs_to_many :photos
    has_and_belongs_to_many :products
  end
end