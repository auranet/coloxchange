class ContactSourceUpdates < ActiveRecord::Migration
  def self.up
    rename_column :users, :referer, :referrer
    add_column :users, :referring_site, :string
    add_column :users, :keywords, :text
  end

  def self.down
    rename_column :users, :referrer, :referer
    remove_column :users, :referring_site
    remove_column :users, :keywords
  end
end
