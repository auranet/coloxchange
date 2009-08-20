module Engines
  class Plugin
    class List < Array
      def [](name_or_index)
        if name_or_index.is_a?(Fixnum)
          super
        else
          self.find { |plugin| plugin.name.to_s == name_or_index.to_s }
        end
      end

      def by_precedence
        reverse
      end
    end
  end
end