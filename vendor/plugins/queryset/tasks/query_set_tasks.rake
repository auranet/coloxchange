namespace :db do
  task :create_queryset_test_db => :environment do
    create_database(ActiveRecord::Base.configurations["queryset_test"])
  end
end