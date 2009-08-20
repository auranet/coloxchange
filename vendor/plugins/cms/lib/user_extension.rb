module UserExtension
  self.admin_action_array.push(["Add to mailing list",:add_to_mailing_list])
  self.modifiers.push([:has_many,:articles,{:order => "articles.created_at DESC"}],[:has_and_belongs_to_many,:favorite_articles,{:class_name => "Article",:order => "articles.created_at DESC"}])
end