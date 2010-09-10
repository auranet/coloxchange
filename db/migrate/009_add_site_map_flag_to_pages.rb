class AddSiteMapFlagToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :appears_on_sitemap, :boolean, :default => false
  end

  def self.down
    remove_column :pages, :appears_on_sitemap
  end
end
