class FindADataCenterAPI < ActionWebService::API::Base
  inflect_names false
  api_method :authenticate, :expects => [{:email => :string}, {:password => :string}], :returns => [:string]
  api_method :create, :expects => [{:token => :string}, {:contact => :string}], :returns => [:boolean]
  api_method :quote, :expects => [{:token => :string}, {:contact => :string}, {:quote => :string}], :returns => [:boolean]
end