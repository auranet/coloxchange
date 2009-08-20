module QuerySetExtension # :nodoc:all
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def dates(field,kind,arguments = {})
      return DateSet.new(self.to_s).dates(field,kind,arguments)
    end

    def filter(arguments = {})
      return QuerySet.new(self.to_s).filter(arguments)
    end

    def match(column,against,options = {})
      options = {:boolean => false}.update(options)
      if options[:conditions]
        options[:conditions][0] << " AND (MATCH(#{column.is_a?(Array) ? column.join(",") : column}) AGAINST (?#{" IN BOOLEAN MODE" if options[:boolean]}))"
        options[:conditions].push(options[:boolean] ? against.split(" ").join(", ") : against)
      else
        options[:conditions] = ["MATCH(#{column.is_a?(Array) ? column.join(",") : column}) AGAINST (?#{" IN BOOLEAN MODE" if options[:boolean]})",options[:boolean] ? against.split(" ").join(", ") : against]
      end
      self.find(:all,:conditions => options[:conditions],:select => options[:boolean] ? "*,MATCH(#{column.is_a?(Array) ? column.join(",") : column}) AGAINST ('#{against}') AS relevance" : nil,:order => options[:boolean] ? "relevance DESC" : nil)
    end
  
    def query_set_sanitize_sql_array
      sanitize_sql_array
    end
  end
end

# DateSet will retrieve all of the unique dates for which a record exists.
#   BlogPost.dates(:created_at,:month) # => [#<Date>,#<Date>]
class DateSet # :nodoc:all
  attr_accessor :model,:options # :nodoc:

  # Returns a sorted array of unique dates for which this record exists.
  #   BlogPost.dates(:created_at,:month) # => [#<Date>,#<Date>]
  #
  # * :field - Must be a date, time, or datetime column for this ActiveRecord::Base model
  # * :kind - Must be one of [:year,:month,:day]; specifies how to group the dates
  # * :options - Optional. Pass any options you would pass to ActiveRecord::Base#find to restrict results further
  def dates(field,kind,options = {})
    case kind.to_s.downcase.to_sym
    when :month
      kind = "Month"
    when :year
      kind = false
    when :day
      kind = "Day"
    else
      raise DateSet::DateKindError, "`#{kind}` is not a valid date type. Must be one of [:year,:month,:day]"
    end
    dates = []
    options[:select] = "DISTINCT #{"EXTRACT(#{kind.upcase} FROM #{field}) AS #{kind.downcase}, " if kind}EXTRACT(YEAR FROM #{field}) AS year"
    options[:order] = field
    for model in self.model.find(:all,options)
      dates.push(Date.new(model["year"].to_i,(model["month"] || "1").to_i,(model["day"] || "1").to_i))
    end
    dates
  end

  def initialize(model) # :nodoc:
    self.model = model.to_s.constantize
  end


  class DateKindError < StandardError # :nodoc:all
  end
end

# QuerySet will allow for lazy filter-chaining on ActiveRecord models, allowing users to expand queries in complex, cross-table ways without touching the database
# until a database call is made implicitly (through one of count, each, empty?, or size) or explicitly (through find)
#
# ==Filtering
# ===Basics
#
# All QuerySets consist of a set of key-value pairs, allowing users to set any number of filtering options. Each key in a QuerySet starts with the name of the
# reflection or column we're filtering on, and optionally ends with a modifier (e.g. "contains", "gt", or "in"). Separate reflections, columns, and modifiers with
# a double-underscore (__) to split queries up. For example:
#
#   BlogPost.filter(:name__contains => "July") # => All BlogPosts whose names are LIKE '%July%'
#   BlogPost.filter(:user__first_name__contains => "Alice") # => All BlogPosts whose users' first_name columns are LIKE '%Alice%'
#
# Some basic modifiers are:
# ====is => `column = value`
#
#   BlogPost.filter(:user_id__is => 1)
#   # This query can also be simplified as:
#   BlogPost.filter(:user_id => 1)
#
# ====not => `column != value`
#
#   BlogPost.filter(:user_id__not => 1)
#
# ===Strings
#
# ====contains => `column LIKE '%value%'`
#
#   BlogPost.filter(:title__contains => "July")
#
# ====starts_with => `column LIKE 'value%'`
#
#   BlogPost.filter(:title__starts_with => "J")
#
# ====ends_with => `column LIKE '%value'`
#
#   BlogPost.filter(:title__ends_with => "y")
#
# To make any string filter case-insensitive, append the filter (or the key part of the key-value pair) with "_i":
#
#   BlogPost.filter(:title__contains => "Case Sensitive")
#   BlogPost.filter(:title__contains_i => "CaSE iNSeNSiTiVE")
#
# ===Numbers & dates
#
# ====gt => `column > value`
#
#   BlogPost.filter(:created_at__gt => 3.months.ago)
#
# ====gte => `column >= value`
#
#   BlogPost.filter(:created_at__gte => 9.months.from_now) # uh oh
#
# ====lt => `column < value`
#
#   BlogPost.filter(:created_at__lt => 1.day.ago)
#
# ====ltee => `column >= value`
#
#   BlogPost.filter(:created_at__lte => 1.month.from_now)
# 
# ====in => `column IN (value1,value2,...)`
# 
#   BlogPost.filter(:user_id__in => [1,2,3,6])
#
# ====not_in => `column NOT IN (value1,value2,...)`
# 
#   BlogPost.filter(:user_id__not_in => [4,5])
# 
# ====range => `column BETWEEN value1 AND value2`
# 
#   BlogPost.filter(:created_at__range => [1.day.ago,1.day.from_now])
# 
# ===NULL values
#
# * :null(true|false) => Executes `column IS (NOT) NULL`
# * :not_null(true|false) => A different way of expressing the above
#   BlogPost.filter(:user_id__null => true) # => All blog_posts with no user_id
class QuerySet
  attr_accessor :count_cache,:model,:conditions,:distinct,:includes,:joins,:logger,:options,:record_cache,:reflections,:table_name # :nodoc:
  include Enumerable

  # AND's a new QuerySet's conditions to this one's.
  #   companies = Company.filter(:active => true) # => QuerySet for all active companies
  #   companies & Company.filter(:name__starts_with => "20 Odd") # => QuerySet for all active companies whose names start w/string "20 Odd"
  # The supplied QuerySet must have been generated through the receiver's model. For example, you cannot chain a Company.filter QuerySet to a User.filter QuerySet
  def &(queryset)
    join_queryset(queryset,:bind => true)
  end

  # OR's a new QuerySet's conditions to this one's.
  #   companies = Company.filter(:name__starts_with => "20 Odd") # => QuerySet for all companies whose names start w/string "20 Odd"
  #   companies | Company.filter(:name__starts_with => "Sasser") # => QuerySet for all companies whose names start w/string "20 Odd" OR "Sasser"
  # The supplied QuerySet must have been generated through the receiver's model. For example, you cannot chain a Company.filter QuerySet to a User.filter QuerySet
  def |(queryset)
    join_queryset(queryset,:bind => true,:operator => "OR")
  end

  # Return the number of matching records for this QuerySet
  def count(*args)
    find_by,options = build_options(args)
    return self.model.count(options)
  end

  def condition(*args)
    join_conditions([args])
  end

  # Yields `record` to &block for each matching record for this QuerySet
  #   Company.filter(:active => true).each do |company|
  #     p company # => Company instance
  #   end
  def each
    for record in self.cached_records
      yield record
    end
  end

  # Returns boolean for whether or not any records matched current QuerySet
  #   User.filter(:login => "flip",:active => true).empty? # => false
  def empty?
    self.size == 0
  end

  # Extend existing QuerySet with additional filters.
  #   companies = Company.filter(:name__contains => "20 Odd") # => QuerySet
  #   companies.filter(:active => true) # => filtered QuerySet
  def filter(arguments)
    new_conditions = []
    for key,value in arguments
      new_conditions.push(build_condition(key,value))
    end
    join_conditions(new_conditions)
  end

  # Perform ActiveRecord::Base#find for this QuerySet with the QuerySet's conditions applied. Accepts all arguments ActiveRecord::Base#find accepts.
  # Call this explicitly if you don't need to use QuerySet's implicit find methods.
  def find(*args)
    find_by,options = build_options(args)
    return self.model.find(find_by,options)
  end

  def initialize(model) # :nodoc:
    self.conditions, self.includes, self.joins = [], [], []
    self.options, self.reflections = {}, {}
    self.model = model.to_s.constantize
    self.table_name = self.model.table_name
    for key,reflection in self.model.reflections
      next if reflection.options[:polymorphic]
      new_reflection = {:class_name => reflection.class_name,:macro => reflection.macro.to_sym,:foreign_key => reflection.primary_key_name.to_s,:table_name => reflection.class_name.constantize.table_name}
      if new_reflection[:macro] == :has_and_belongs_to_many
        new_reflection[:association_foreign_key] = reflection.association_foreign_key
        new_reflection[:join_table] = reflection.options[:join_table]
      end
      self.reflections[key.to_sym] = new_reflection
    end
    self.logger = defined?(RAILS_DEFAULT_LOGGER) ? RAILS_DEFAULT_LOGGER : Logger.new(STDOUT)
    yield self if block_given?
  end

  # Perform pagination using the QuerySet's conditions, includes, and joins. Requires Mislav's will_paginate gem installed.
  def paginate(options)
    join_conditions(options.delete(:conditions)) if options.has_key?(:conditions)
    join_includes(options.delete(:include)) if options.has_key?(:include)
    self.model.paginate(options.merge(:conditions => self.conditions,:include => self.includes,:joins => self.joins))
  end

  # Returns count for any records matching current QuerySet
  def size
    self.cached_count
  end

  protected
  def cached_count
    self.count_cache ||= self.count
  end

  def cached_records
    self.record_cache ||= self.find(:all)
  end

  private
  def build_condition(key,value)
    terms = key.to_s.split("__")
    term = terms.shift
    if (reflection = self.reflections[term.to_sym]) && !(terms.last =~ /(not_empty|is_not_empty|isnotempty)/)
      new_queryset = reflection[:class_name].constantize.filter(terms.unshift(!(terms.first =~ modifiers).nil? ? "id" : nil).compact.join("__") => value)
      join_conditions([new_queryset.conditions])
      self.includes.push(new_queryset.includes.empty? ? term.to_sym : {term.to_sym => new_queryset.includes})
      return nil
    else
      term = "#{self.table_name}.#{term}"
    end
    value = value.to_param if value.is_a?(ActiveRecord::Base)
    if terms.last && terms.last.gsub(/_i$/,"") =~ modifiers
      modifier_shorthand = terms.pop.to_s
      case_insensitive = false
      if modifier_shorthand =~ /_i$/
        term = "LOWER(#{term})"
        case_insensitive = true
        modifier_shorthand.gsub!(/_i$/,"")
        value.downcase! if value.is_a?(String)
      end
      if use_new_modifier = deprecated_modifiers[modifier_shorthand.to_sym]
        self.logger.warn("\nQUERYSET DEPRECATION WARNING: `#{modifier_shorthand}` will be replaced by `#{use_new_modifier}` in QuerySet 2.0")
      end
      case modifier_shorthand
      when "contains","not_contains","like","starts_with","startswith","ends_with","endswith"
        condition = "#{"NOT " if modifier_shorthand =~ /(not_contains|does_not_contain)/}LIKE ?"
        value = "#{"\%" if modifier_shorthand =~ /(contains|not_contains|does_not_contain|like|endswith|ends_with)/}#{value}#{"\%" if modifier_shorthand =~ /(contains|like|startswith|starts_with)/}"
      when "false","true"
        condition = "= ?"
        value = modifier_shorthand == "false" ? false : true
      when "gt"
        condition = "> ?"
      when "gte"
        condition = ">= ?"
      when "lt"
        condition = "< ?"
      when "lte"
        condition = "<= ?"
      when "in","not_in","notin"
        if value.is_a?(Array) || value.is_a?(Range)
          value = value.to_a if value.is_a?(Range)
          return nil if value.empty?
          column = self.model.columns.select{|column| column.name.to_s.downcase == term.gsub(/\(\)/,"").split(".").last.to_s.downcase}[0]
          string = column && column.type == :string
          value = value.collect{|sub_value| "#{"'" if string}#{sub_value.is_a?(ActiveRecord::Base) ? sub_value.to_param : sub_value.is_a?(String) && string && case_insensitive ? sub_value.downcase : sub_value}#{"'" if string}"}.join(",")
        end
        condition = "#{"NOT " if modifier_shorthand =~ /(notin|not_in)/}IN (#{value})"
        value = nil
      when "range"
        if value.first.is_a?(Date) && value.last.is_a?(Date)
          value[1] -= 1
          condition = ">= ? AND #{term} <= ?"
        else
          condition = "BETWEEN ? AND ?"
        end
      when "null","is_null","isnull","not_null","is_not_null","isnotnull"
        condition = "IS#{" NOT" if (modifier_shorthand =~ /(not_null|is_not_null|isnotnull)/ && value) || (modifier_shorthand =~ /^(null|is_null|isnull)$/ && !value)} NULL"
        value = nil
      when "not_empty","is_not_empty","isnotempty"
        # TODO: this is extremely breakable w/the joins feature requiring a string and allowing the user to supply their own joins to the final query
        term = "#{reflection[:join_table] || reflection[:table_name]}.#{reflection[:foreign_key]}"
        condition = "= #{self.table_name}.id"
        # self.distinct = true
        self.includes.push(reflection[:name])
        # self.joins.push("LEFT JOIN #{reflection[:join_table] || reflection[:table_name]} ON #{term} #{condition}")
        value = nil
      when "empty","is_empty","isempty"
        # TODO: Add SQL support for empty relationships
        raise QuerySet::ModifierError, "`#{modifier_shorthand}` is not implemented"
      when "not"
        condition = "!= ?"
      when "is"
        condition = "= ?"
      else
        raise QuerySet::ModifierError, "Valid modifier `#{modifier_shorthand}` is not implemeneted. Sorry!"
      end
    else
      condition = "= ?"
      terms.pop if terms.last == "is"
    end
    if terms.size == 1
      modifier_shorthand = terms.shift
      case modifier_shorthand
      when "year","month","day"
        term = "EXTRACT(#{modifier_shorthand.upcase} FROM #{term})"
      else
        raise QuerySet::ModifierError, "`#{modifier_shorthand}` is an invalid modifier (in #{key} => #{value.inspect})"
      end
    end
    return condition ? ["#{term} #{condition}",value].flatten.compact : nil
  end

  def build_options(args)
    find_by = args.shift || :all
    options = args.pop || {}
    options[:include] = [options[:include],self.includes].flatten.compact.uniq
    options[:joins] = [options[:joins],self.joins].flatten.compact.uniq.join(" ")
    if options[:conditions]
      join_conditions(options[:conditions].is_a?(Array) ? [options[:conditions]] : [[options[:conditions]]])
    else
      options[:conditions] = self.conditions
    end
    options.delete(:conditions) if options[:conditions].empty?
    options.delete(:include) if options[:include].empty?
    options.delete(:joins) if options[:joins].empty?
    return find_by,options
  end

  def deprecated_modifiers
    {:like => "contains",
      :startswith => "starts_with",
      :endswith => "ends_with",
      :notin => "not_in",
      :is_null => "null",
      :isnull => "null",
      :is_not_null => "not_null",
      :isnotnull => "not_null",
      :is_empty => "empty",
      :isempty => "empty",
      :is_not_empty => "not_empty",
      :isnotempty => "not_empty"
    }
  end

  def expire_cache
    self.count_cache = nil
    self.record_cache = nil
  end

  def join_conditions(new_conditions,options = {})
    expire_cache
    unless new_conditions.empty?
      options = {:bind => false,:operator => "AND"}.update(options)
      left,right = [],[]
      for condition in new_conditions.compact
        left.push(condition.shift)
        right.push(condition)
      end
      left = left.join(" AND ")
      left = "(#{left})" if options[:bind]
      left = [self.conditions.shift,left].compact.delete_if{|i| i == ""}.join(" #{options[:operator].strip} ")
      left = "(#{left})" if options[:bind]
      self.conditions = [left,[self.conditions,right.flatten]].flatten
    end
    self
  end

  def join_includes(new_includes)
    for to_include in new_includes
      self.includes.push(to_include) unless self.includes.any?{|already_included| (!already_included.is_a?(Hash) && !to_include.is_a?(Hash) && already_included.to_sym == to_include.to_sym) || already_included == to_include}
    end
  end

  def join_queryset(queryset,options = {})
    join_conditions([queryset.conditions.clone],options)
    join_includes(queryset.includes.clone)
    self
  end

  def modifiers
    /^(like|contains|not_contains|does_not_contain|starts_with|startswith|ends_with|endswith|gt|gte|lt|lte|in|notin|not_in|range|null|is_null|isnull|not_null|is_not_null|isnotnull|match|empty|is_empty|isempty|not_empty|is_not_empty|isnotempty|is|not|true|false)$/
  end

  class ModifierError < StandardError # :nodoc:all
  end
end
ActiveRecord::Base.send :include, QuerySetExtension