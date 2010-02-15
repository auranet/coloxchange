class CreateMarkets < ActiveRecord::Migration
  def self.up
    create_table :markets do |t|
      t.integer :position
      t.string :city, :limit => 32
      t.string :state, :limit => 3
    end
  end

  def self.down
    drop_table :markets
  end
end
