class Menu < NameBasedModel
  admin :fields => [:name],:reflections => [:menu_items]
  has_many :menu_items, :order => 'menu_items.position ASC'

  def cached?
    !Dir[File.join(RAILS_ROOT, 'tmp', 'cache', '*', "#{self.slug}_menu.cache")].empty?
  end
end