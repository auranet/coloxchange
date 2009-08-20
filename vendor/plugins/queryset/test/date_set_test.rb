# Make sure we've got ActiveRecord, since this is an AR extension...
require "rubygems"
require "active_record"
require "active_record/fixtures"
require File.join(File.dirname(__FILE__),"..","lib","query_set")
require "rake"
require "rake/testtask"
require "test/unit"

# Load up the local testing databases; the following code is modified from GeoKit by Andre Lewis and Bill Eisenhauer
config = YAML::load(File.open(File.join(File.dirname(__FILE__),"db","queryset_database.yml")))["queryset_test"]
config["database"] = File.join(File.dirname(__FILE__),"db","queryset_test.sqlite3") if config["adapter"] == "sqlite3"
ActiveRecord::Base.configurations["queryset_test"] = config
Rake::TestTask.new("db::create_queryset_test_db")
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations["queryset_test"])

# Load the test schema into the database
load(File.join(File.dirname(__FILE__),"db","schema.rb"))

# Load fixtures
Test::Unit::TestCase.fixture_path = File.join(File.dirname(__FILE__),"fixtures")

class BlogPost < ActiveRecord::Base #nodoc: all
  belongs_to :user
end
class User < ActiveRecord::Base #nodoc: all
  belongs_to :company
  has_many :blog_posts,:order => [:created_at]
end

class DateSetTest < Test::Unit::TestCase
  fixtures :blog_posts,:users

  def test_001_default
    assert_equal BlogPost.dates(:created_at,:month).size,3
  end
end

# Revert to original ActiveRecord connection to continue with other test suites
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations["queryset_test"])