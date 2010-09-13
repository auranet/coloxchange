module MailExtension
  module InstanceMethods
    def contact_confirmation(contact)
      from("no-reply@colocationxchange.com")
      recipients(contact.name_with_email)
      subject("Thank you for your recent request")
      body(:contact => contact)
    end

    def contact_request(contact)
      from("no-reply@colocationxchange.com")
      mailing_list = MailingList.find_by_slug("contact-requests")
      recipients((mailing_list ? mailing_list.users : User.filter(:admin => true)).collect{|user| user.name_with_email})
      subject("New contact request from #{contact.name}")
      body(:contact => contact)
    end

    def quote(quote)
      from("no-reply@colocationxchange.com")
      mailing_list = MailingList.find_by_slug("quote-requests")
      recipients((mailing_list ? mailing_list.users : User.filter(:admin => true)).collect{|user| user.name_with_email})
      subject("New #{quote.type.humanize.downcase} quote request from #{quote.contact.name}")
      body(:contact => quote.contact, :quote => quote)
    end
  end
end