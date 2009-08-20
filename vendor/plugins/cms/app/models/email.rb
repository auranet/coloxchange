class Email
  def self.admin_add_title
    "Compose an e-mail"
  end

  def self.admin_name
    "E-Mail"
  end

  def self.admin_url
    {:controller => "admin",:action => "email_compose"}
  end
end