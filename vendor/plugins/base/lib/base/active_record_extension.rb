module Base
  module ActiveRecordExtension
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module ClassMethods
      def admin(options = {})
      end

      def attach(options = {})
        options = {:required => false}.merge(options)
        self.send(:attr_accessor,:path)
        self.send(:belongs_to,:file,:class_name => 'FileStore')
        self.send(:before_validation,Proc.new{|document|
          if document.path.respond_to?(:read)
            document.file.destroy if document.file
            document.file = FileStore.create(:path => document.path)
          end
        })
        self.send(:validates_presence_of,:file,:on => :create) if options[:required]
      end

      def belongs_to_and_edits_inline(reflection_name,options = {},save_options = {})
        save_options = {:match_column => :name,:destroy_conditions => nil,:create_if_not_found => true}.update(save_options)
        self.send(:belongs_to,reflection_name,options)
        self.send(:attr_accessor,"#{reflection_name}_name".to_sym)
        reflection = self.reflections[reflection_name.to_sym]
        if save_options[:destroy_conditions] != nil
          class_eval <<-EOV
          def check_destroy_#{reflection_name}
            self.#{reflection_name}.destroy if self.#{reflection_name}.#{save_options[:destroy_conditions].collect{|condition| "send(#{condition})"}.join(".")}
          end
          EOV
        end
        class_eval <<-EOV
        def #{reflection_name}_name
          @#{reflection_name}_name || @#{reflection_name}_name = self.#{reflection_name} ? self.#{reflection_name}.name : ""
        end
        EOV
        if save_options[:create_if_not_found]
          self.send(:before_save,"save_#{reflection_name}".to_sym)
          class_eval <<-EOV
          def save_#{reflection_name}
            if self.#{reflection_name}_name
              #{"self.check_destroy_#{reflection_name}" if save_options[:destroy_conditions] != nil}
              self.#{reflection_name} = #{reflection.class_name}.find_or_create_by_#{save_options[:match_column]}(self.#{reflection_name}_name)
            end
          end
          EOV
        end
      end

      def edit_inline(class_method,reflection,options,save_options)
        validate = (options[:validate].nil? ? {:validate => false}.update(save_options) : options).delete(:validate)
        self.send(class_method,reflection,options)
        self.send(:attr_accessor,"new_#{reflection}".to_sym)
        self.send(validate ? :before_validation : :before_save,"save_#{reflection}".to_sym)
        klass = self.reflections[reflection.to_sym].class_name
        class_eval <<-EOV
        def add_#{reflection}(item)
          instance = self.#{reflection}.build(item) unless (!item[:id].blank? && item[:id] != "0") && instance = #{klass}.find(:first,:conditions => ["id = ?",item[:id]])
          if !instance.new_record?
            instance.update_attributes(item)
            self.#{reflection} << instance
          end
          if !instance.valid?
            #{validate ? "self.errors.add_to_base(instance.error_list(:string))" : "self.#{reflection} -= [instance]"}
          end
        end

        def save_#{reflection}
          unless self.new_#{reflection}.nil?
            self.#{reflection}.clear
            if self.new_#{reflection}.is_a?(Array)
              for item in self.new_#{reflection}
                unless #{validate.is_a?(Symbol) ? "item[#{validate.inspect}].blank?" : "item.keys.all?{|key| item[key].blank?}"}
                  self.add_#{reflection}(item)
                end
              end
            elsif self.new_#{reflection}.is_a?(Hash)
              for key,item in self.new_#{reflection}
                self.add_#{reflection}(item)
              end
            end
            #{validate ? "self.errors.empty?" : "true"}
          end
        end 
        EOV
      end

      def has_and_belongs_to_many_and_edits_inline(reflection,options = {},save_options = {})
        logger.warn("DEPRECATION WARNING: The save_options hash will be removed from has_and_belongs_to_many_and_edits_inline. Please move :validate into the first options hash. (your hash: #{save_options.inspect})") unless save_options.empty?
        edit_inline(:has_and_belongs_to_many,reflection,options,save_options)
      end

      def has_many_and_edits_inline(reflection,options = {},save_options = {})
        logger.warn("DEPRECATION WARNING: The save_options hash will be removed from has_many_and_edits_inline. Please move :validate into the first options hash. (your hash: #{save_options.inspect})") unless save_options.empty?
        edit_inline(:has_many,reflection,options,save_options)
      end

      def monitor(*args)
        for arg in args
          class_eval <<-EOV
            attr_accessor :old_#{arg}
            def #{arg}_changed?
              !self.old_#{arg}.nil? && self.old_#{arg} != self.#{arg}
            end
          EOV
        end
        class_eval <<-EOV
          protected
          def after_find
            #{args.collect{|arg| "self.old_#{arg} = self.attributes['#{arg}']"}.join("\n")}
          end
        EOV
      end

      def state(name, constants = {}, options = {})
        options = {:aggregates => {}, :reverse => false}.merge(options)
        class_name = name.to_s.split(/(_| )/).collect{|part| part.titleize}.join.gsub(' ', '').gsub(/_{2,}/, '_')
        constants = constants.collect{|key, value| [value.is_a?(Array) ? value.first : value, key, (value.is_a?(Array) ? value.last : key).to_s.downcase.gsub(/[^a-z_ ]/, '').strip.gsub(' ', '_').gsub(/_{2,}/, '_').upcase]}.sort{|a, b| a[0] <=> b[0]}
        raise constants.inspect
        aggregates = options[:aggregates].collect{|key, value| [value.collect{|a| constants.select{|constant| constant[1].slugify == a.slugify}[0][2]}, key.to_s.downcase.gsub(/[^a-z ]/, '').strip.gsub(' ', '_').upcase]}
        if options[:reverse]
          constants.reverse!
          aggregates.reverse!
        end
        hash = "{#{constants.collect{|constant| "#{self.to_s}::#{class_name}::#{constant[2]} => \"#{constant[1]}\""}.join(", ")}}"
        class_eval <<-EOV
        module #{class_name}
          #{constants.collect{|constant| "#{constant[2]} = #{constant[0].inspect}"}.join("\n")}
          #{aggregates.collect{|aggregate| "#{aggregate[1]} = [#{aggregate[0].join(', ')}]"}.join("\n")}

          def self.hash
            #{hash}
          end

          def self.[](status)
            hash[status]
          end

          def self.options
            self.hash.keys.sort.collect{|key| [self.hash[key], key]}
          end

          def self.integer_for_name(name)
            self.hash.select{|key, value| value.slugify == name.slugify}.first.first
          rescue
            nil
          end
        end

        def #{name}_name
          #{self.to_s}::#{class_name}.hash[self.attributes[#{name}]] || self.attributes[#{name}]
        end
        EOV
        for constant in constants
          class_eval <<-EOV
          def #{name}_#{constant[2].slugify.gsub("-", "_")}?
            self.#{name} == #{self.to_s}::#{class_name}::#{constant[2]}
          end
          EOV
        end
        for aggregate in aggregates
          class_eval <<-EOV
          def #{name}_#{aggregate[1].slugify.gsub("-", "_")}?
            #{self.to_s}::#{class_name}::#{aggregate[1]}.include?(self.#{name})
          end
          EOV
        end
      end
    end

    module InstanceMethods
      def error_list(mode = :ul)
        case mode.to_sym
        when :ul
          error_string = "<ul class=\"#{Base::Style.error_list_class}\">"
          self.errors.each {|field,error| error_string << "<li>#{error[0,1].upcase == error[0,1] ? error : "#{field.humanize.capitalize} #{error}"}</li>" unless error.nil? }
          "#{error_string}</ul>"
        when :string
          error_array = []
          self.errors.each {|field,error| error_array.push("#{error[0,1].upcase == error[0,1] ? error : "#{field.humanize.capitalize} #{error}"}")}
          error_array.join(", ")
        else
          raise "mode #{mode} not recognized"
        end
      end
    end
  end
end