ActiveRecord::Schema.define(:version => 1) do
  create_table :blog_posts,:force => true do |t|
    t.column :user_id,:integer
    t.column :title,:string
    t.column :created_at,:time
  end
  create_table :companies,:force => true do |t|
    t.column :name,:string
  end
  create_table :phone_numbers,:force => true do |t|
    t.column :user_id,:integer
    t.column :area_code,:integer
    t.column :number,:string
    t.column :long_distance,:boolean,:default => false
  end
  create_table :users,:force => true do |t|
    t.column :company_id,:integer
    t.column :first_name,:string
    t.column :last_name,:string
    t.column :created_at,:datetime
  end
end