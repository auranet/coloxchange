class PluginList < Array
  def [](name_or_index)
    if name_or_index.is_a?(Fixnum)
      super
    else
      self.find { |plugin| plugin.name.to_s == name_or_index.to_s }
    end
  end

  def by_precedence(&block)
    if block_given?
      reverse.each { |x| yield x }
    else
      reverse
    end
  end
end