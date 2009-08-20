class InitialInstallation < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :name
    end
    add_index :companies, :name
    create_table :addresses do |t|
      t.text :street
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country, :default => "United States"
      t.decimal :lat, :precision => 15, :scale => 10
      t.decimal :lng, :precision => 15, :scale => 10
    end
    add_index :addresses, :lat
    add_index :addresses, :lng
    create_table :emails do |t|
      t.integer :user_id
      t.integer :position
      t.string :address
      t.string :kind, :limit => 10
    end
    add_index :emails, :user_id
    add_index :emails, :position
    add_index :emails, :kind
    create_table :file_stores do |t|
      t.integer :user_id
      t.string :caption
      t.string :url
      t.string :path
      t.string :type
    end
    add_index :file_stores, :user_id
    add_index :file_stores, :type
    create_table :name_based_models do |t|
      t.string :name
      t.string :slug
      t.string :type
    end
    add_index :name_based_models, :slug
    add_index :name_based_models, :type
    create_table :notes do |t|
      t.integer :contact_id
      t.integer :user_id
      t.text :body
      t.datetime :created_at
    end
    add_index :notes, :contact_id
    add_index :notes, :user_id
    create_table :notes_quotes, :id => false do |t|
      t.integer :note_id
      t.integer :quote_id
    end
    add_index :notes_quotes, [:note_id, :quote_id]
    create_table :phones do |t|
      t.integer :user_id
      t.integer :position
      t.string :number
      t.string :kind, :limit => 10
    end
    add_index :phones, :user_id
    add_index :phones, :position
    add_index :phones, :kind
    create_table :quotes do |t|
      # For all quotes...
      t.integer :contact_id
      t.integer :status_id
      t.string :product, :limit => 128
      t.string :type, :limit => 20
      # For bandwidth quotes...
      t.string :bandwidth_requirements, :limit => 128
      # For equipment quotes...
      t.string :price_target
      t.boolean :new_equipment
      t.datetime :created_at
    end
    add_index :quotes, :contact_id
    add_index :quotes, :type
    add_index :quotes, :created_at
    create_table :quote_addresses do |t|
      t.integer :address_id
      t.integer :quote_id
      t.integer :position
    end
    add_index :quote_addresses, [:address_id, :quote_id]
    add_index :quote_addresses, :position
    create_table :quote_data_centers do |t|
      t.string :data_center_slug
      t.integer :quote_id
    end
    add_index :quote_data_centers, :data_center_slug
    add_index :quote_data_centers, :quote_id
    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end
    add_index :sessions, :session_id
    add_index :sessions, :updated_at
    create_table :users do |t|
      t.integer :company_id
      t.integer :photo_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :title
      t.string :password, :limit => 40
      t.string :salt, :limit => 40
      t.boolean :admin, :default => false
      t.boolean :active, :default => true
      t.boolean :authenticates, :default => true
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :last_login
      t.string :uniq_id
      t.boolean :change_password, :default => false
      t.string :kind, :default => "prospect"
      t.string :type
      t.string :lead_source
      t.integer :status, :default => 0
    end
    add_index :users, :company_id
    add_index :users, :photo_id
    add_index :users, :email, :unique => true
    add_index :users, :admin
    add_index :users, :active
    add_index :users, :authenticates
    add_index :users, :type
    add_index :users, :status
    create_table :websites do |t|
      t.integer :user_id
      t.integer :position
      t.string :url
      t.string :kind, :limit => 10
    end
    add_index :websites, :user_id
    add_index :websites, :position
    add_index :websites, :kind
    Rails.plugins[:admin].migrate(1)
    Rails.plugins[:cms].migrate(1)
  end

  def self.down
    Rails.plugins[:admin].migrate(0)
    Rails.plugins[:cms].migrate(0)
    drop_table :companies
    drop_table :emails
    drop_table :file_stores
    drop_table :name_based_models
    drop_table :phones
    drop_table :quotes
    drop_table :sessions
    drop_table :users
    drop_table :websites
  end
end
