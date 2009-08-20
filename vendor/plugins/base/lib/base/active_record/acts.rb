module ActiveRecord
  module Acts
    module List
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_list(options = {})
          configuration = { :column => "position", :scope => "1 = 1" }
          configuration.update(options) if options.is_a?(Hash)

          configuration[:scope] = "#{configuration[:scope]}_id".intern if configuration[:scope].is_a?(Symbol) && configuration[:scope].to_s !~ /_id$/

          if configuration[:scope].is_a?(Symbol)
            scope_condition_method = %(
            def scope_condition
              if #{configuration[:scope].to_s}.nil?
                "#{configuration[:scope].to_s} IS NULL"
              else
                "#{configuration[:scope].to_s} = \#{#{configuration[:scope].to_s}}"
              end
            end
            )
          else
            scope_condition_method = "def scope_condition() \"#{configuration[:scope]}\" end"
          end

          class_eval <<-EOV
          include ActiveRecord::Acts::List::InstanceMethods

          def acts_as_list_class
            ::#{self.name}
          end

          def position_column
            '#{configuration[:column]}'
          end

          #{scope_condition_method}

          before_destroy :remove_from_list
          before_create  :add_to_list_bottom
          EOV
        end
      end

      module InstanceMethods
        def insert_at(position = 1)
          insert_at_position(position)
        end

        def move_lower
          return unless lower_item

          acts_as_list_class.transaction do
            lower_item.decrement_position
            increment_position
          end
        end

        def move_higher
          return unless higher_item

          acts_as_list_class.transaction do
            higher_item.increment_position
            decrement_position
          end
        end

        def move_to_bottom
          return unless in_list?
          acts_as_list_class.transaction do
            decrement_positions_on_lower_items
            assume_bottom_position
          end
        end

        def move_to_top
          return unless in_list?
          acts_as_list_class.transaction do
            increment_positions_on_higher_items
            assume_top_position
          end
        end

        def remove_from_list
          if in_list?
            decrement_positions_on_lower_items
            update_attribute position_column, nil
          end
        end

        def increment_position
          return unless in_list?
          update_attribute position_column, self.send(position_column).to_i + 1
        end

        def decrement_position
          return unless in_list?
          update_attribute position_column, self.send(position_column).to_i - 1
        end

        def first?
          return false unless in_list?
          self.send(position_column) == 1
        end

        def last?
          return false unless in_list?
          self.send(position_column) == bottom_position_in_list
        end

        def higher_item
          return nil unless in_list?
          acts_as_list_class.find(:first,:conditions => "#{scope_condition} AND #{position_column} = #{(send(position_column).to_i - 1).to_s}")
        end

        def lower_item
          return nil unless in_list?
          acts_as_list_class.find(:first,:conditions => "#{scope_condition} AND #{position_column} = #{(send(position_column).to_i + 1).to_s}")
        end

        def in_list?
          !send(position_column).nil?
        end

        private
        def add_to_list_top
          increment_positions_on_all_items
        end

        def add_to_list_bottom
          self[position_column] = bottom_position_in_list.to_i + 1
        end

        def scope_condition() "1" end

          def bottom_position_in_list(except = nil)
            item = bottom_item(except)
            item ? item.send(position_column) : 0
          end

          def bottom_item(except = nil)
            conditions = scope_condition
            conditions = "#{conditions} AND #{self.class.primary_key} != #{except.id}" if except
            acts_as_list_class.find(:first, :conditions => conditions, :order => "#{position_column} DESC")
          end

          def assume_bottom_position
            update_attribute(position_column, bottom_position_in_list(self).to_i + 1)
          end

          def assume_top_position
            update_attribute(position_column, 1)
          end

          def decrement_positions_on_higher_items(position)
            acts_as_list_class.update_all("#{position_column} = (#{position_column} - 1)", "#{scope_condition} AND #{position_column} <= #{position}")
          end

          def decrement_positions_on_lower_items
            return unless in_list?
            acts_as_list_class.update_all("#{position_column} = (#{position_column} - 1)", "#{scope_condition} AND #{position_column} > #{send(position_column).to_i}")
          end

          def increment_positions_on_higher_items
            return unless in_list?
            acts_as_list_class.update_all("#{position_column} = (#{position_column} + 1)", "#{scope_condition} AND #{position_column} < #{send(position_column).to_i}")
          end

          def increment_positions_on_lower_items(position)
            acts_as_list_class.update_all("#{position_column} = (#{position_column} + 1)", "#{scope_condition} AND #{position_column} >= #{position}")
          end

          def increment_positions_on_all_items
            acts_as_list_class.update_all("#{position_column} = (#{position_column} + 1)",  "#{scope_condition}")
          end

          def insert_at_position(position)
            remove_from_list
            increment_positions_on_lower_items(position)
            self.update_attribute(position_column, position)
          end
        end 
      end

      module Tree
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_tree(options = {})
            configuration = { :foreign_key => "parent_id", :order => nil, :counter_cache => nil }
            configuration.update(options) if options.is_a?(Hash)

            belongs_to :parent, :class_name => name, :foreign_key => configuration[:foreign_key], :counter_cache => configuration[:counter_cache]
            has_many :children, :class_name => name, :foreign_key => configuration[:foreign_key], :order => configuration[:order], :dependent => :destroy

            class_eval <<-EOV
            include ActiveRecord::Acts::Tree::InstanceMethods

            def self.roots
              find(:all, :conditions => "#{configuration[:foreign_key]} IS NULL", :order => #{configuration[:order].nil? ? "nil" : %Q{"#{configuration[:order]}"}})
            end

            def self.root
              find(:first, :conditions => "#{configuration[:foreign_key]} IS NULL", :order => #{configuration[:order].nil? ? "nil" : %Q{"#{configuration[:order]}"}})
            end
            EOV
          end
        end

        module InstanceMethods
          def ancestors
            node, nodes = self, []
            nodes << node = node.parent while node.parent
            nodes
          end

          def root
            node = self
            node = node.parent while node.parent
            node
          end

          def siblings
            self_and_siblings - [self]
          end

          def self_and_siblings
            parent ? parent.children : self.class.roots
          end
        end
      end
      
      # module Versioned
      #   def self.included(base)
      #     base.extend(ClassMethods)
      #   end
      # 
      #   module ClassMethods
      #     def acts_as_versioned
      #       self.send(:has_many,:versions,{:class_name => "#{self.to_s}Version",:foreign_key => "current_version_id"})
      #       self.send(:before_save,:acts_as_versioned_increment)
      #       const_set("#{self.to_s}Version",Class.new(ActiveRecord::Base))
      #       version_class = "#{self.to_s}Version".constantize
      #       if !version_class.table_exists?
      #         const_set("#{self.to_s}VersionMigration",Class.new(ActiveRecord::Migration))
      #         version_migration_class = "#{self.to_s}VersionMigration"
      #         version_migration_class.class_eval <<-EOV
      #           def self.up
      #             create_table :#{self.table_name}_versions do |t|
      #               t.column :
      #             end
      #           end
      #         EOV
      #       end
      #     end
      #   end
      # 
      #   module InstanceMethods
      #     def get_version(version)
      #       {}
      #     end
      # 
      #     def revert_to_version(version)
      #       self.update_attributes(self.get_version(version).attributes)
      #     end
      # 
      #     def versions
      #       self.version_class.find(:all)
      #     end
      # 
      #     private
      #     def acts_as_versioned_increment
      #       self.version += 1
      #     end
      # 
      #     def acts_as_versioned_update
      #       "#{self.to_s}Version".constantize.create(self.attributes.update({:current_version_id => self.id}))
      #     end
      #   end
      # end
    end
  end