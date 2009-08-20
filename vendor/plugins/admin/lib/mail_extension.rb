module MailExtension
  module InstanceMethods
    def new_user_password(user)
      from(Base.emails[:robot])
      recipients(user.name_with_email)
      subject("Your new account for #{Base.domain_short}")
      body({:user => user})
    end
  end
end