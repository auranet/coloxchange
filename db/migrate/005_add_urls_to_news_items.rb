class AddUrlsToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :url, :string
  end

  def self.down
    remove_column :news_items, :url, :string
  end
end
