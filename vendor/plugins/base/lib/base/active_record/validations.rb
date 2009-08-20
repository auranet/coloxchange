module ActiveRecord
  module Validations
    module ClassMethods
      def validates_overall_uniqueness_of(*attr_names)
        configuration = {:message => "has already been taken"}
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)
        validates_each(attr_names,configuration) do |record,attr_name,value|
          records = self.find(:all,:conditions=> ["#{attr_name} = ?",value])
          record.errors.add(attr_name,configuration[:message]) if records.size > 0 and records[0].id != record.id
        end
      end
    end
  end
end