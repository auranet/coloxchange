if Rails.plugins[:admin]
  Admin.models.push("Advertisement","Article","Category","Email","MailingList","Menu","Newsletter","NewsItem","Page")
  Admin.skip_actions.push("advertisement","article","clickthrough","news_item","page","page_preview","press_release")
end