module Base
  module Style
    mattr_accessor :error_field_class,:error_list_class
    self.error_field_class = "invalid-field"
    self.error_list_class = "error-list"
  end
end