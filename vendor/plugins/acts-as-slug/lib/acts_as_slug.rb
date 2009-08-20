module ActiveRecord
  module Acts
    module Slug
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_slug(config = {})
          options = {:column => "slug",:name => "name",:scope => "1 = 1",:validate => true}
          options.update(config) if config.is_a?(Hash)
          self.send(:validates_presence_of,options[:column],:message => options[:message]) if options[:validate]
          self.send(:before_validation,:save_slug)
          if options[:scope].is_a?(Symbol) && options[:scope].to_s !~ /_id$/
            options[:scope] = "#{options[:scope]}_id".intern
          elsif options[:scope].is_a?(Array) && options[:scope].size == 1
            options[:scope] = options[:scope].pop
          end
          if options[:scope].is_a?(Symbol)
            scope_condition_method = %(
            def slug_scope
              if #{options[:scope].to_s}.nil?
                "#{options[:scope].to_s} IS NULL"
              else
                "#{options[:scope].to_s} = \#{#{options[:scope].to_s}}"
              end
            end
            )
          elsif options[:scope].is_a?(Array)
            scopes = options[:scope].collect{|column| "#{column.to_s} = \#{#{column.to_s}}"}
            scope_condition_method = %(
            def slug_scope
              "#{scopes.join(" AND ")}"
            end
            )
          else
            scope_condition_method = %(
            def slug_scope
              "#{options[:scope]}"
            end
            )
          end
          if options[:append]
            append_method = %(
            def slug_append
              "-#{options[:append]}"
            end
            )
          else
            append_method = %(
            def slug_append
              ""
            end
            )
          end
          if options[:prepend]
            prepend_method = %(
            def slug_prepend
              "#{options[:prepend]}-"
            end
            )
          else
            prepend_method = %(
            def slug_prepend
              ""
            end
            )
          end

          class_eval <<-EOV
          include ActiveRecord::Acts::Slug::InstanceMethods
          def slug_name_column
            '#{options[:name]}'.to_sym
          end 
          def slug_slug_column
            '#{options[:column]}'
          end
          #{scope_condition_method}
          #{append_method}
          #{prepend_method}
          EOV
        end
      end

      module InstanceMethods
        private
        def save_slug
          if self.respond_to?(self.slug_slug_column) && self.respond_to?(self.slug_name_column) && (self.send(self.slug_slug_column).nil? || (self.send(self.slug_slug_column) && self.send(self.slug_slug_column).strip.blank?))
            core_slug = "#{self.slug_prepend}#{self.send(self.slug_name_column).to_s}#{self.slug_append}".downcase.gsub(/[^a-z09_ -]/,"").gsub(/ {2,}/," ").strip.gsub(/(_| )/,"-").gsub(/-{2,}/,"")
            new_slug = core_slug
            i = 0
            conditions = [self.slug_scope]
            unless self.new_record?
              conditions[0] << " AND id != ?"
              conditions.push(self.id)
            end
            conditions[0] << " AND #{self.slug_slug_column} = ?"
            while self.class.count({:conditions => [conditions,new_slug].flatten}) > 0
              i += 1
              new_slug = "#{core_slug}-#{i}"
            end
            self.send("#{self.slug_slug_column}=","#{new_slug}")
          end
        end
      end
    end
  end
end

module StringExtension
  def slugify
    self.downcase.gsub(/[^a-z0-9_ -]/,"").strip.gsub(/(_| )/,"-").gsub(/-{2,}/,"-")
  end
end
String.send :include,StringExtension