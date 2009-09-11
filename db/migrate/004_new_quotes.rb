class NewQuotes < ActiveRecord::Migration
  def self.up
    add_column :quotes, :space, :string
    add_column :quotes, :bandwidth, :string
    add_column :quotes, :power, :string
    add_column :quotes, :target_date, :date
  end

  def self.down
    remove_column :quotes, :space
    remove_column :quotes, :bandwidth
    remove_column :quotes, :power
    remove_column :quotes, :target_date
  end
end
