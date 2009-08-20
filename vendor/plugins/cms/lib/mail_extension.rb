module MailExtension
  module InstanceMethods
    def newsletter(newsletter,users)
      from(Base.emails[:newsletter])
      recipients(Base.emails[:newsletter])
      bcc(users.collect{|user| user.name_with_email})
      subject("#{site_name}: #{newsletter.date.strftime("%B %Y")} Newsletter")
      body(:newsletter => newsletter)
    end
  end
end