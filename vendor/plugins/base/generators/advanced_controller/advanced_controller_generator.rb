class AdvancedControllerGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      routes = File.join("config","routes.rb")
      routes_string = File.read(routes)
      routes_string = <<-RTSTRNG
#{routes_string.gsub(/\n^end$/,"")}

  # #{class_name.titleize.pluralize}
  map.connect "#{file_name.tableize}",:controller => "#{file_name}",:action => "index"
  map.connect "#{file_name.tableize}/add",:controller => "#{file_name}",:action => "edit"
  map.connect "#{file_name.tableize}/page/:page",:controller => "#{file_name}",:action => "index",:requirements => {:page => /\d+/}
  map.connect "#{file_name.tableize}/:id",:controller => "#{file_name}",:action => "show",:requirements => {:id => /\\d+/}
  map.connect "#{file_name.tableize}/:id/delete",:controller => "#{file_name}",:action => "destroy",:requirements => {:id => /\\d+/}
  map.connect "#{file_name.tableize}/:id/edit",:controller => "#{file_name}",:action => "edit",:requirements => {:id => /\\d+/}
end
RTSTRNG
      File.open(routes,"w+").write(routes_string)
      # Check for class naming collisions.
      m.class_collisions class_path,"#{class_name}Controller","#{class_name}ControllerTest","#{class_name}Helper"

      # Controller,helper,views,and test directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join("app/controllers",class_path)
      m.directory File.join("app/helpers",class_path)
      m.directory File.join("app/views",class_path,file_name)
      m.directory File.join('test/fixtures', class_path)
      m.directory File.join("test/functional",class_path)
      m.directory File.join('test/unit', class_path)

      # Controller class,functional test,and helper class.
      m.template "controller.rb",File.join("app/controllers",class_path,"#{file_name}_controller.rb")
      m.template "functional_test.rb",File.join("test/functional",class_path,"#{file_name}_controller_test.rb")
      # m.template "helper.rb",File.join("app/helpers",class_path,"#{file_name}_helper.rb")
      m.template "delete.html.erb",File.join("app/views",file_name,"delete.html.erb")
      m.template "edit.html.erb",File.join("app/views",file_name,"edit.html.erb")
      m.template "index.html.erb",File.join("app/views",file_name,"index.html.erb")
      m.template "view.html.erb",File.join("app/views",file_name,"view.html.erb")
      m.template "model.rb",File.join("app/models","#{file_name}.rb")
      m.template 'unit_test.rb',  File.join('test/unit', class_path, "#{file_name}_test.rb")
      m.template 'fixtures.yml',  File.join('test/fixtures', "#{table_name}.yml")

      # View template for each action.
      actions.without("filter").each do |action|
        path = File.join("app/views",class_path,file_name,"#{action}.html.erb")
        m.template "view.html.erb",path,:assigns => {:action => action,:path => path}
      end
    end
  end
end
