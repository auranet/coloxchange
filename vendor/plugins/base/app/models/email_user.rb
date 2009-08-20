class EmailUser < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "email"
  set_primary_key nil
  set_table_name :users
end