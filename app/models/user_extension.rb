module UserExtension
  # self.modifiers.push(
  #   [:has_and_belongs_to_many,:messages,{:association_foreign_key => :user_id,:join_table => :message_recipients,:order => :created_at}],
  #   [:has_and_belongs_to_many,:monitored_quotes,{:class_name => 'Quote',:conditions => ["quotes.status IN (0,1,4,5,6)"],:join_table => :monitored_quotes}],
  #   [:has_many,:sent_messages,{:class_name => 'Message',:foreign_key => :from_id,:order => :created_at}],
  #   [:has_many,:tasks,{:order => 'tasks.complete, tasks.due ASC'}]
  # )
  module InstanceMethods
  end
end