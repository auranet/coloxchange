class BaseInitialInstallation < ActiveRecord::Migration
  def self.up
    create_table :file_stores do |t|
      t.column :user_id,:integer
      t.column :caption,:string
      t.column :url,:string
      t.column :path,:string
      t.column :type,:string
    end
    create_table :name_based_models do |t|
      t.column :name,:string
      t.column :slug,:string
      t.column :type,:string
    end
    create_table :users do |t|
      t.column :photo_id,:integer
      t.column :email,:string
      t.column :username,:string
      t.column :first_name,:string
      t.column :last_name,:string
      t.column :password,:string
      t.column :admin,:boolean,:default => false
      t.column :active,:boolean,:default => true
      t.column :authenticates,:boolean,:default => true
      t.column :created_at,:datetime
      t.column :updated_at,:datetime
      t.column :last_login,:datetime
      t.column :uniq_id,:string
      t.column :verified,:boolean,:default => false
      t.column :change_password,:boolean,:default => false
      t.column :type,:string
    end
  end

  def self.down
    drop_table :file_stores
    drop_table :name_based_models
    drop_table :users
  end
end