class ContactReferers < ActiveRecord::Migration
  def self.up
    add_column :users, :referer, :string
    add_column :quote_data_centers, :name, :string
  end

  def self.down
    remove_column :users, :referer
    remove_column :quote_data_centers, :name
  end
end
