class AdminInitialInstallation < ActiveRecord::Migration
  def self.up
    create_table :admin_actions do |t|
      t.column :user_id,:integer
      t.column :user_name,:string
      t.column :action,:string
      t.column :model,:string
      t.column :model_id,:integer
      t.column :model_name,:string
      t.column :description,:text
      t.column :created_at,:datetime
    end
    create_table :admin_permissions do |t|
      t.column :admin_role_id,:integer
      t.column :model,:string
      t.column :add,:boolean,:default => true
      t.column :edit,:boolean,:default => true
      t.column :delete,:boolean,:default => true
      t.column :must_own,:boolean,:default => false
    end
    create_table :admin_roles do |t|
      t.column :name,:string
      t.column :omnipotent,:boolean,:default => false
    end
    create_table :admin_roles_users,:id => false do |t|
      t.column :admin_role_id,:integer
      t.column :user_id,:integer
    end
    create_table :admin_widgets do |t|
      t.column :user_id,:integer
      t.column :widget,:string
      t.column :collapsed,:boolean,:default => false
    end
    # create_table :auth_tokens do |t|
    #   t.column :user_id,:integer
    #   t.column :token,:string
    #   t.column :expires,:datetime
    # end
    create_table :notifications do |t|
      t.column :admin_role_id,:integer
      t.column :icon,:string,:default => "default"
      t.column :name,:string
      t.column :message,:text
      t.column :url,:string
      t.column :view_url,:string
      t.column :created_at,:datetime
      t.column :viewed,:boolean,:default => false
    end
    create_table :notification_views do |t|
      t.column :notification_id,:integer
      t.column :user_id,:integer
    end
    add_column :users,:enable_email,:boolean,:default => false
    add_column :users,:admin_skin,:string,:default => "inkDrop v2"
  end

  def self.down
    drop_table :admin_actions
    drop_table :admin_permissions
    drop_table :admin_roles
    drop_table :admin_roles_users
    drop_table :admin_widgets
    # drop_table :auth_tokens
    drop_table :notifications
    drop_table :notification_views
    remove_column :users,:enable_email
    remove_column :users,:admin_skin
  end
end
