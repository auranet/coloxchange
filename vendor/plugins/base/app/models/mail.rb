class Mail < ActionMailer::Base
  include MailExtension

  def exception(params,exception,request,user)
    from(admin_email)
    recipients(admin_email)
    subject("ERROR: #{params[:controller]}##{params[:action]} (#{exception.class}) #{exception.message.inspect}")
    body({:exception => exception,:params => params,:request => request,:user => user})
  end

  def user_password(user,password)
    from(Base.emails[:robot])
    recipients(user.name_with_email)
    subject("Password reset on #{domain_short}")
    body({:login_url => "#{domain}/#{Base.urls["login"]}",:password => password})
  end

  def user_verification(user)
    from(Base.emails[:robot])
    recipients(user.name_with_email)
    subject("Verify your account for #{domain_short}")
    body({:user => user,:verification_url => "#{domain}/#{Base.urls["user_verification"]}/#{user.uniq_id}"})
  end
end