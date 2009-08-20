module MailExtension
  module InstanceMethods
    def contact_confirmation(contact)
      from(Base.emails[:robot])
      recipients(contact.name_with_email)
      subject("Thank you for your recent request")
      body(:contact => contact)
    end

    def contact_request(contact)
      from(contact.name_with_email)
      mailing_list = MailingList.find_by_slug("contact-requests")
      recipients((mailing_list ? mailing_list.users : User.filter(:admin => true)).collect{|user| user.name_with_email})
      request_type = contact.details ? "managed service" : "contact"
      subject("New #{request_type} request from #{contact.name}")
      body(:contact => contact,:request_type => request_type)
    end
  end
end