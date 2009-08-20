# class CMSNewClicks < ActiveRecord::Migration
#   def self.up
#     rename_table :advertisement_clicks,:clicks
#     rename_column :clicks,:advertisement_id,:item_id
#     add_column :clicks,:item_type,:string
#     Click.find(:all).each{|click| click.update_attribute(:item_type,"Advertisement")}
#     rename_table :advertisement_impressions,:impressions
#     rename_column :impressions,:advertisement_id,:item_id
#     add_column :impressions,:item_type,:string
#     Impression.find(:all).each{|impression| impression.update_attribute(:item_type,"Advertisement")}
#     rename_table :advertisement_clicks_keywords,:clicks_keywords
#     rename_column :clicks_keywords,:advertisement_click_id,:click_id
#   end
# end;CMSNewClicks.up
class CMSInitialInstallation < ActiveRecord::Migration
  def self.up
    add_column :users,:subscriber,:boolean,:default => false
    create_table :clicks_keywords,:id => false do |t|
      t.integer :click_id
      t.integer :keyword_id
    end
    create_table :advertisement_regions do |t|
      t.string :name
      t.decimal :sw_lat,:precision => 15,:scale => 10
      t.decimal :sw_lng,:precision => 15,:scale => 10
      t.decimal :ne_lat,:precision => 15,:scale => 10
      t.decimal :ne_lng,:precision => 15,:scale => 10
    end
    create_table :advertisement_regions_advertisements,:id => false do |t|
      t.integer :advertisement_region_id
      t.integer :advertisement_id
    end
    create_table :advertisements do |t|
      t.integer :photo_id
      t.string :name
      t.string :uniq_id
      t.boolean :active,:default => true
      t.date :ends_on
      t.integer :width
      t.integer :height
      t.string :kind
      t.string :photo_url
      t.text :body
      t.boolean :regional
      t.string :url
    end
    create_table :advertisements_categories,:id => false do |t|
      t.column :advertisement_id,:integer
      t.column :category_id,:integer
    end
    create_table :advertisements_keywords,:id => false do |t|
      t.integer :advertisement_id
      t.integer :keyword_id
    end
    create_table :articles do |t|#,:options => "ENGINE=MyISAM" do |t|
      t.column :photo_id,:integer
      t.column :user_id,:integer
      t.column :name,:string
      t.column :slug,:string
      t.column :body,:text
      t.column :body_filter,:string,:default => "markdown"
      t.column :preview,:text
      t.column :meta_title,:string
      t.column :meta_description,:text
      t.column :meta_keywords,:text
      t.column :publish_date,:date
      t.column :created_at,:datetime
    end
    add_index :articles,[:name]
    # execute "CREATE FULLTEXT INDEX body ON articles (body)"
    create_table :articles_categories,:id => false do |t|
      t.column :article_id,:integer
      t.column :category_id,:integer
    end
    create_table :articles_users,:id => false do |t|
      t.column :article_id,:integer
      t.column :user_id,:integer
    end
    create_table :clicks do |t|
      t.integer :item_id
      t.string :item_type
      t.integer :user_id
      t.string :ip,:limit => 15
      t.string :referer
      t.datetime :created_at
      t.string :url
    end
    create_table :impressions do |t|
      t.integer :item_id
      t.string :item_type
      t.datetime :created_at
    end
    create_table :keywords do |t|
      t.string :name
      t.integer :hits,:default => 0
    end
    add_index :keywords,[:id,:name]
    create_table :keywords_users,:id => false do |t|
      t.integer :keyword_id
      t.integer :user_id
    end
    create_table :mailing_list_users do |t|
      t.column :mailing_list_id,:integer
      t.column :user_id,:integer
      t.column :subscribed,:boolean,:default => true
      t.column :unsubscribed_at,:datetime
      t.column :unsubscribed_reason,:text
    end
    create_table :menu_items do |t|
      t.column :menu_id,:integer
      t.column :parent_id,:integer
      t.column :menu_items_count,:integer
      t.column :position,:integer
      t.column :name,:string
      t.column :point_to,:string,:default => "page"
      t.column :page_id,:integer
      t.column :auto_build,:boolean,:default => true
      t.column :auto_update,:boolean,:default => false
      t.column :controller,:string
      t.column :action,:string
      t.column :id_,:string
      t.column :url,:string
    end
    create_table :news_items do |t|
      t.string :name
      t.string :slug
      t.text :body
      t.date :date
      t.string :kind
      t.string :extra_url
    end
    create_table :news_item_contacts do |t|
      t.integer :news_item_id
      t.string :name
      t.string :company
      t.string :phone
      t.string :email
    end
    create_table :newsletters do |t|
      t.column :name,:string
      t.column :description,:text
      t.column :date,:date
      t.column :sent,:boolean,:default => false
    end
    create_table :newsletter_articles do |t|
      t.column :newsletter_id,:integer
      t.column :article_id,:integer
      t.column :photo_id,:integer
      t.column :position,:integer
      t.column :align,:string,:default => "left",:limit => 6
    end
    create_table :pages do |t|#,:options => "ENGINE=MyISAM" do |t|
      t.column :user_id,:integer
      t.column :parent_id,:integer
      t.column :pages_count,:integer
      t.column :position,:integer
      t.column :active,:boolean,:default => true
      t.column :name,:string
      t.column :slug,:string
      t.column :suppress_title,:boolean,:default => false
      t.column :attached,:boolean,:default => false
      t.column :controller,:string
      t.column :action,:string
      t.column :id_,:string
      t.column :body_filter,:string,:default => "markdown"
      t.column :body,:text
      t.column :meta_title,:string
      t.column :meta_description,:text
      t.column :meta_keywords,:text
      t.column :created_at,:datetime
      t.column :version,:integer,:default => 1
    end
    add_index :pages,[:slug,:name]
    # execute "CREATE FULLTEXT INDEX body ON pages (body)"
    create_table :page_sections do |t|#,:options => "ENGINE=MyISAM" do |t|
      t.column :page_id,:integer
      t.column :section,:string
      t.column :body_filter,:string,:default => "markdown"
      t.column :body,:text
    end
    # execute "CREATE FULLTEXT INDEX body ON page_sections (body)"
    create_table :snippets do |t|#,:options => "ENGINE=MyISAM" do |t|
      t.column :name,:string
      t.column :body,:text
    end
    add_index :snippets,[:name]
    # execute "CREATE FULLTEXT INDEX body ON snippets (body)"
    create_table :snippet_attachments do |t|
      t.column :snippet_id,:integer
      t.column :attach_to,:string,:default => "page"
      t.column :page_id,:integer
      t.column :controller,:string
      t.column :action,:string
      t.column :id_,:string
      t.column :area,:string
    end
  end

  def self.down
    remove_column :users,:subscriber
    drop_table :clicks
    drop_table :clicks_keywords
    drop_table :advertisement_regions
    drop_table :advertisement_regions_advertisements
    drop_table :advertisements
    drop_table :advertisements_categories
    drop_table :advertisements_keywords
    drop_table :articles
    drop_table :articles_categories
    drop_table :articles_users
    drop_table :keywords
    drop_table :keywords_users
    drop_table :mailing_list_users
    drop_table :menu_items
    drop_table :news_items
    drop_table :news_item_contacts
    drop_table :newsletters
    drop_table :newsletter_articles
    drop_table :pages
    drop_table :page_sections
    drop_table :snippets
    drop_table :snippet_attachments
  end
end