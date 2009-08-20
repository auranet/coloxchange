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

class Company < ActiveRecord::Base #nodoc: all
  has_many :users
end
class PhoneNumber < ActiveRecord::Base #nodoc: all
  belongs_to :user
end
class User < ActiveRecord::Base #nodoc: all
  belongs_to :company
  has_many :phone_numbers,:order => [:area_code,:number]
end

class QuerySetTest < Test::Unit::TestCase
  fixtures :companies,:phone_numbers,:users

  def test_001_default
    companies = Company.filter(:name => "The Tattered Cover")
    assert !companies.empty?
  end

  def test_002_one_table_jump
    users = User.filter(:company__name => "The Tattered Cover")
    assert !users.empty?
  end

  def test_003_two_table_jump
    phone_numbers = PhoneNumber.filter(:user__company__name => "The Tattered Cover")
    assert !phone_numbers.empty?
  end

  def test_004_lazy_chaining
    # TODO: These are failing despite them being case-sensitive - is SQLite case-sensitive on '%term%' queries?
    companies = Company.filter(:name__starts_with => "The")
    # assert_equal 2,companies.size
    companies.filter(:name__contains => "Livable")
    assert_equal 1,companies.size
  end

  def test_005_lazy_chaining_with_one_table_jump
    # TODO: These are failing despite them being case-sensitive - is SQLite case-sensitive on '%term%' queries?
    companies = Company.filter(:name__starts_with => "The")
    # assert_equal companies.size,2
    companies.filter(:users__last_name => "Ouray")
    assert_equal 1,companies.size
  end

  def test_006_lazy_chaining_with_two_table_jump
    phone_numbers = PhoneNumber.filter(:area_code => 410)
    assert_equal 2,phone_numbers.size
    phone_numbers.filter(:user__last_name => "Hickenlooper")
    assert_equal 1,phone_numbers.size
    phone_numbers.filter(:user__company__name__contains => "Pint's")
    assert_equal 1,phone_numbers.size
    phone_numbers.filter(:user__company__name => "ReadyTalk")
    assert phone_numbers.empty?
  end

  def test_007_and
    phone_numbers = PhoneNumber.filter(:area_code => 410)
    assert_equal 2,phone_numbers.size
    phone_numbers & PhoneNumber.filter(:area_code => 303)
    assert phone_numbers.empty?
  end

  def test_008_or
    phone_numbers = PhoneNumber.filter(:area_code => 410)
    assert_equal 2,phone_numbers.size
    phone_numbers | PhoneNumber.filter(:area_code => 303)
    assert_equal 3,phone_numbers.size
  end

  def test_009_string_modifiers
    for modifier in %w(like contains starts_with startswith)
      assert_equal 1,Company.filter("name__#{modifier}" => "Coors").size
    end
    for modifier in %w(ends_with endswith)
      assert_equal 1,Company.filter("name__#{modifier}" => "Field").size
    end
    assert_equal 1,Company.filter(:name__is => "Coors Field").size
    assert_equal Company.count-1,Company.filter(:name__not => "Coors Field").size
  end

  def test_010_string_modifiers_case_insensitive
    # TODO: This is failing because of the same SQLite case-insensitivity issue - weird
    for modifier in %w(like contains starts_with startswith)
      assert_not_equal Company.filter("name__#{modifier}" => "The").size,Company.filter("name__#{modifier}_i" => "The").size
    end
  end

  def test_011_numeric_modifiers
    users = User.filter(:id__range => [1,4])
    assert_equal 4,users.size
    users.filter(:id__not => 4)
    assert_equal 3,users.size
    assert_equal 4,User.filter(:id__gt => 1).size
    assert_equal 5,User.filter(:id__gte => 1).size
    assert_equal 2,User.filter(:id__lt => 3).size
    assert_equal 3,User.filter(:id__lte => 3).size
    assert_equal 2,User.filter(:id__in => [1,2]).size
    assert_equal 3,User.filter(:id__not_in => [1,2]).size
  end

  def test_012_null_and_empty_modifiers
    assert_equal 1,User.filter(:company_id__null => true).size
    assert_equal 4,User.filter(:company_id__null => false).size
    assert_equal 4,User.filter(:company_id__not_null => true).size
    assert_equal 1,User.filter(:company_id__not_null => false).size
    assert_raises QuerySet::ModifierError do
      Company.filter(:users__empty => false)
    end
    assert_equal 4,Company.filter(:users__not_empty => true).size
  end

  def test_013_implicit_active_record_conversion
    users = User.find(:all)
    user_ids = users.collect{|user| user.id}
    assert_equal Company.filter(:users__id__in => user_ids).size,Company.filter(:users__id__in => users).size
    assert_equal Company.filter(:users__id => users.first).size,Company.filter(:users__id => users.first.id).size
  end

  def test_014_enumerable
    phone_numbers = PhoneNumber.filter(:id__in => 1..10)
    for phone_number in phone_numbers
      assert phone_number.is_a?(ActiveRecord::Base)
    end
  end

  def test_015_extended_find
    companies = Company.filter(:name__contains_i => "e")
    assert_equal companies.find(:all).size,companies.size
    assert_not_equal companies.find(:all,:conditions => ["companies.name NOT LIKE '%The%'"]),companies.find(:all)
  end
end

# Revert to original ActiveRecord connection to continue with other test suites
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations["queryset_test"])