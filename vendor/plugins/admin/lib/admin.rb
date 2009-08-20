module Admin
  mattr_accessor :actions,:admin_phone,:app_name,:colors,:controllers,:enable_email,:exportable,:extensions,:models,:per_page,:protected_models,:skip_actions
  self.actions = []
  self.admin_phone = "303.353.5242"
  self.app_name = "Deimos CMS"
  self.colors = []
  self.controllers = ["main"]
  self.enable_email = false
  self.exportable = false
  self.extensions = {}
  self.models = ["User","FileStore","Photo"]
  self.per_page = 30
  self.protected_models = ["AdminAction","AdminRole"]
  self.skip_actions = ["wsdl"]

  def self.startup
    include_controller_name = self.controllers.size > 1
    for controller in self.controllers.sort
      controller_name = "#{controller.to_s.titleize}: "
      for action in "#{controller}_controller".camelize.constantize.action_method_names.without(Admin.skip_actions).sort
        if (action =~ /\w+_context/).nil?
          self.actions.push(["#{controller_name if controller_name}#{action == "index" ? "Home" : action.titleize}","#{controller}/#{action}"]) unless controller == "main" && Rails.plugins[:cms] && ((!Configuration.newsletter && action == "newsletter") || action =~ /^(page_preview)$/)
        end
      end
    end
  end

  module ActiveRecordExtension
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module ClassMethods
      def admin(options = {})
        self.admin_check_options(options)
        for key in self.admin_valid_options
          # Write the important data to the class; if we've already been here, any subsequent calls to admin will only overwrite the old values
          self.send("admin_write_#{key}",options[key]) unless self.admin_touched? && !options.has_key?(key)
          self.class_eval <<-EOV
          def self.admin_#{key}
            read_inheritable_attribute(:admin_#{key})
          end
          def self.admin_#{key}=(value)
            self.send("admin_write_#{key}",value)
          end
          EOV
        end
        write_inheritable_attribute(:admin_touched,true)
      end

      # Used for caching: whether or not we've already done the heavy lifting on this model
      def admin_touched?
        read_inheritable_attribute(:admin_touched)
      end

      def admin_check_options(options)
        invalid = []
        for key,value in options
          invalid.push(key) unless admin_valid_options.include?(key.to_sym)
        end
        raise "Option#{"s" unless invalid.size == 1} \"#{invalid.collect{|invalid| ":#{invalid}"}.join(", ")}\" #{invalid.size == 1 ? "is" : "are"} not recognized by the admin method" unless invalid.empty?
      end

      def admin_name
        self.send(:admin) unless self.admin_touched?
        read_inheritable_attribute(:admin_name)
      end

      def admin_options
        self.send(:admin) unless self.admin_touched?
        {:actions => self.admin_actions,:browse_columns => self.admin_browse_columns,:conditions => self.admin_conditions,:deletable => self.admin_deletable,:importable => self.admin_importable,:include => self.admin_include,:order => self.admin_order}
      end

      def admin_valid_options
        [:actions,:browse_columns,:bulk_fields,:conditions,:deletable,:fields,:filters,:importable,:import_columns,:include,:maps,:name,:new_only,:old_only,:order,:reflections,:search_fields]
      end

      def admin_write_actions(value)
        write_inheritable_attribute(:admin_actions,value || [])
      end

      def admin_write_browse_columns(value)
        write_inheritable_attribute(:admin_browse_columns,value || ["name"])
      end

      def admin_write_bulk_fields(value)
        fields = []
        if value
          instance = self.new
          value = [value] unless value.is_a?(Array)
          for field in value do
            if !field.is_a?(Hash)
              field = {:label => field.to_s.humanize,:name => field.to_sym,:options => {}}
            else
              field = {:name => field.keys.first,:label => field.values.first[:label] ? field.values.first[:label] : field.keys.first.to_s.humanize,:options => field.values.first[:options],:type => field.values.first[:type]}
            end
            if reflection = self.reflections[field[:name]]
              field[:type] = :reflection
            else
              field[:type] = instance.column_for_attribute(field[:name]).type unless field[:type]
            end
            fields.push(field)
          end
        end
        write_inheritable_attribute(:admin_bulk_fields,fields)
      end

      def admin_write_conditions(value)
        write_inheritable_attribute(:admin_conditions,value || nil)
      end

      def admin_write_deletable(value)
        write_inheritable_attribute(:admin_deletable,value.nil? ? true : value)
      end

      def admin_write_fields(value)
        fields = value || ["*"]
        field_array = []
        expand = false
        if fields && !fields.empty?
          expand = fields.include?("*")
          for field in fields.without("*")
            field_array.push(field)
          end
        end
        without = field_array.collect{|field| field.is_a?(Hash) ? field.keys.first.to_s : field.to_s}
        if expand && self.table_exists?
          for field in self.new.attributes.without(without).keys.sort
            field_array.push(field)
          end
        end
        write_inheritable_attribute(:admin_fields,field_array.without(:id,"id"))
      end

      def admin_write_filters(value)
        write_inheritable_attribute(:admin_filters,value && !value.empty? ? value : [:name])
      end

      def admin_write_importable(value)
        write_inheritable_attribute(:admin_importable,value.nil? ? false : value)
      end

      def admin_write_import_columns(value)
        write_inheritable_attribute(:admin_import_columns,value || [])
      end

      def admin_write_include(value)
        write_inheritable_attribute(:admin_include,value || [])
      end

      def admin_write_maps(value)
        write_inheritable_attribute(:admin_maps,value.nil? ? false : value)
      end

      def admin_write_name(value)
        write_inheritable_attribute(:admin_name,(value || self.name.titleize).pluralize)
      end

      def admin_write_new_only(value)
        write_inheritable_attribute(:admin_new_only,value || [])
      end

      def admin_write_old_only(value)
        write_inheritable_attribute(:admin_old_only,value || [])
      end

      def admin_write_order(value)
        explicit = !value.nil?
        order = value || "#{table_name}.name"
        if !explicit && self.table_exists? && self.new.respond_to?(:move_to_top)
          order = "#{table_name}.position"
        elsif !order.include?(".")
          order = order.split(",").collect{|p| "#{table_name}.#{p}"}.join(",")
        end
        write_inheritable_attribute(:admin_order,order)
      end

      def admin_write_reflections(value)
        nreflections = value || ["*"]
        reflection_array = []
        if nreflections != :none
          expand = nreflections.include?("*")
          for reflection in nreflections.without("*")
            reflection_array.push(reflection.is_a?(Hash) ? reflection : reflection.to_sym)
          end
        else
          expand = false
        end
        for reflection in self.reflections.keys.without(reflection_array).collect{|r| r.to_s}.sort
          reflection_array.push(reflection.to_sym)
        end if expand
        write_inheritable_attribute(:admin_reflections,reflection_array)
      end

      def admin_write_search_fields(value)
        fields = value || [:name]
        write_inheritable_attribute(:admin_search_fields,fields.is_a?(Array) ? fields : [fields])
      end
    end

    module InstanceMethods
      def admin_fields(fields = nil,ownership_required = false)
        if !fields
          if fields = self.class.admin_fields
            if fields.is_a?(Hash)
              fieldsets = collect_fields[:grouping]
            end
          else
            fields = self.attributes.keys.sort.collect{|key| key.to_sym}.delete_if {|value| value == :id}
          end
        end
        fields = Marshal::load(Marshal::dump(fields))
        fields.each_with_index do |field,index|
          if field.is_a?(Array)
            fields[index] = self.admin_fields(field,ownership_required)
          elsif !field.is_a?(Hash)
            field = {field => {:label => field.to_s.humanize}}
          elsif !field[field.keys[0]][:label]
            field[field.keys[0]][:label] = field.keys[0].to_s.humanize
          end
          if field.is_a?(Hash) && ((!self.new_record? && !self.class.admin_new_only.empty? && self.class.admin_new_only.include?(field.keys[0])) || (self.new_record? && !self.class.admin_old_only.empty? && self.class.admin_old_only.include?(field.keys[0])))
            field = nil
          end
          fields[index] = field
        end
        return fields.compact
      end

      def admin_filters(load_max_min = false)
        fields,filters,stringfilters = self.admin_fields,[],[]
        for oldfilter in [self.class.admin_filters.without("*"),self.class.admin_filters.include?("*") ? self.attributes.keys : nil].flatten.compact
          # next unless fields.is_a?(Hash) || fields.is_a?(Array)
          name = oldfilter.is_a?(Hash) ? oldfilter.keys.first : oldfilter.to_sym
          field = fields.select{|field| field.keys.first == name.to_s}[0]
          reflection = self.class.reflections[name]
          filter = {:name => name,:label => field ? field.values.first[:label] : name.to_s.humanize,:type => reflection ? reflection.macro : self.column_for_attribute(name).type}
          if oldfilter.is_a?(Hash)
            filter[:combine] = oldfilter.values.first
            filter[:type] = :string
          end
          if filter[:type] == :string
            stringfilters.push(filter)
          else
            if filter[:type] == :text
              next
            elsif filter[:type] == :integer || filter[:type] == :float || filter[:type] == :date || filter[:type] == :datetime
              if load_max_min
                limits = self.class.find_by_sql("SELECT MIN(#{filter[:name]}) AS min, MAX(#{filter[:name]}) AS max FROM #{self.class.table_name}")[0]
                if limits.min && limits.max && limits.min != limits.max
                  filter[:min],filter[:max] = limits.min,limits.max
                else
                  next
                end
              end
            elsif reflection
              reflection_class = reflection.class_name.classify.constantize
              case reflection.macro
              when :belongs_to
                filter[:choices] = reflection_class.find(:all,:order => reflection_class.admin_order).collect{|choice| [choice.name,choice.id]}
              when :has_many,:has_and_belongs_to_many,:has_one
                filter[:choices] = reflection_class.find(:all,:order => reflection_class.admin_order).collect{|choice| [choice.name,choice.id]}
              else
                raise "macro odd: #{reflection.inspect}"
              end
            end
            filters.push(filter)
          end
        end
        for reflection in self.class.admin_reflections
          if self.class.admin_filters.any?{|filter| filter == "*" || filter == reflection.to_s || (filter.is_a?(Hash) && filter.keys.first.to_sym == reflection.to_sym)}
            filter = {:name => reflection,:label => reflection.to_s.humanize,:type => :reflection,:collapsed => true}
            filters.push(filter)
          end
        end
        [stringfilters,filters].flatten.compact
      end
    end
  end
end

ActiveRecord::Base.send :include, Admin::ActiveRecordExtension