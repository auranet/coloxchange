class AuthToken < ActiveRecord::Base
  belongs_to :user

  def self.validate(token,expires = 10)
    if auth_token = self.find(:first,:conditions => ["auth_tokens.token = ? AND auth_tokens.expires < ?",token,DateTime.now])
      auth_token.update_attributes(:expires => expires.minutes.from_now)
      return auth_token.user
    end
    return false
  end

  protected
  def before_create
    self.token = "#{self.user.id}-#{DateTime.now}".encrypt
    self.expires = 10.minutes.from_now unless self.expires
  end
end