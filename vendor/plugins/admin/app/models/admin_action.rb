class AdminAction < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :action,:user_id

  def action_name
    case self.action.to_sym
    when :edit
      "updated"
    when :new
      "created"
    when :delete,:deleteall
      "deleted"
    else
      self.action
    end
  end

  def before_validation_on_create
    self.user_name = self.user.name
  end
end