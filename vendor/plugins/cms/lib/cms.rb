module CMS
  mattr_accessor :advertisement_sizes,:articles_per_page,:content_areas,:hierarchical_menus,:newsletter,:newsletter_url,:news_items_per_page,:page_urls,:search,:sitemap_url,:snippet_positions,:skip_snippet_controllers,:subscriber_fields
  Base.emails[:newsletter] = "newsletter"
  self.advertisement_sizes = {}
  self.articles_per_page = 10
  self.content_areas = {}
  self.hierarchical_menus = false
  self.news_items_per_page = 10
  self.newsletter = false
  self.newsletter_url = "newsletter"
  self.page_urls = {:main => {}}
  self.search = false
  self.skip_snippet_controllers = [:admin]
  self.sitemap_url = "sitemap"
  self.snippet_positions = {}
  self.subscriber_fields = [:subscriber]

  def self.startup
    require "action_controller/test_process"
    url = ActionController::UrlRewriter.new(ActionController::TestRequest.new,nil)
    begin
      Page.table_exists?
      for action in MainController.action_method_names.without(["newsletter","page_preview",Admin.skip_actions].flatten).sort
        page = Page.find_or_initialize_by_attached_and_controller_and_action(true,"main",action)
        page.update_attributes({:slug => url.rewrite(:only_path => true,:controller => "main",:action => action)}.update(page.new_record? ? {:name => action == "index" ? "Homepage" : action.titleize} : {}))# if page.new_record?
        CMS.page_urls[:main][action.to_sym] = true
      end if Page.columns.select{|c| c.name == "attached"}[0]
    rescue
      Engines.logger.warn("Pages uninstalled; running migrations")
    end
    if Rails.plugins[:admin]
      Admin.models.push("Snippet") if !CMS.snippet_positions.empty?
      Admin.extensions[:add_to_mailing_list] = :mailing_list
      Admin.extensions[:expire] = :expire
      Admin.extensions[:preview] = :preview
      Admin.extensions[:send_to_mailing_list] = :mailing_list_send
    end
  end
end