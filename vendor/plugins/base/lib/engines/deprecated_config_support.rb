class Module
  def default_constant(name, value)
    if !(name.is_a?(String) or name.is_a?(Symbol))
      raise "Cannot use a #{name.class.name} ['#{name}'] object as a constant name"
    end
    if !self.const_defined?(name)
      self.class_eval("#{name} = #{value.inspect}")
    end
  end

  def config(*args)
    raise "config expects at least one argument" if args.empty?
    if args[0].is_a?(Hash)
      override = args[0][:force]
      args[0].delete(:force)
      args[0].each { |key, value| _handle_config(key, value, override)}
    else
      _handle_config(*args)
    end
  end

  private
  def _handle_config(name, value=nil, override=false)
    if !self.const_defined?("CONFIG")
      self.class_eval("CONFIG = {}")
    end
    if value != nil
      if override or self::CONFIG[name] == nil
        self::CONFIG[name] = value
      end
    else
      if name.is_a? Array
        name.map { |c| self::CONFIG[c] }
      else
        self::CONFIG[name]
      end
    end
  end
end