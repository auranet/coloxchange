class AddCustomerCodeToContacts < ActiveRecord::Migration
  def self.up
    add_column :users, :customer_code, :string, :limit => 32
  end

  def self.down
    remove_column :users, :customer_code
  end
end
