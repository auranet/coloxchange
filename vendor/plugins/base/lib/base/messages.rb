module Base
  module Messages
    mattr_accessor :email_invalid,:email_taken,:username_illegal,:username_numeric,:username_taken
    mattr_accessor :login_failed,:login_successful,:logout_successful,:user_required,:admin_required
    self.admin_required = "You do not have permission to access this area."
    self.email_invalid = "The e-mail address you supplied is invalid."
    self.email_taken = "An account with that e-mail already exists."
    self.login_failed = "Your login credentials could not be verified."
    self.login_successful = "You have successfully logged in."
    self.logout_successful = "You have successfully logged out."
    self.username_illegal = "Your username contains illegal characters."
    self.username_numeric = "Your username must contain at least one letter."
    self.username_taken = "The username you supplied is taken."
    self.user_required = "You must login to view this page."
  end
end