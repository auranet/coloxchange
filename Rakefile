# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

require File.join(File.dirname(__FILE__), 'vendor', 'plugins', 'thinking-sphinx', 'lib', 'thinking_sphinx', 'tasks')

desc "Seed markets"
task :markets => :environment do
  MARKETS.each do |market|
    puts "Seeding... #{Market.find_or_create_by_city_and_state(market[:city], market[:state]).name}"
  end
end