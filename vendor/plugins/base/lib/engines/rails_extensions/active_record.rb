module Engines::RailsExtensions::ActiveRecord
  def wrapped_table_name(name)
    table_name_prefix + name + table_name_suffix
  end
end

module ::ActiveRecord
  class Base
    extend Engines::RailsExtensions::ActiveRecord
  end
end