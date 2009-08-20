class AdvancedScaffoldGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Check for class naming collisions.
      @controller_path = file_name.pluralize
      @controller_name = class_name.pluralize
      m.class_collisions class_path,"#{@controller_name}Controller","#{@controller_name}ControllerTest","#{@controller_name}Helper"

      # Controller,helper,views,and test directories.
      m.directory File.join('app/models',class_path)
      m.directory File.join("app/controllers",class_path)
      m.directory File.join("app/helpers",class_path)
      m.directory File.join("app/views",class_path,@controller_path)
      m.directory File.join('test/fixtures',class_path)
      m.directory File.join("test/functional",class_path)
      m.directory File.join('test/unit',class_path)

      # Controller class,functional test,and helper class.
      m.template "controller.rb",File.join("app/controllers",class_path,"#{@controller_path}_controller.rb")
      m.template "functional_test.rb",File.join("test/functional",class_path,"#{@controller_path}_controller_test.rb")
      m.template "helper.rb",File.join("app/helpers",class_path,"#{@controller_path}_helper.rb")
      m.template "destroy.html.erb",File.join("app/views",@controller_path,"destroy.html.erb")
      m.template "form.html.erb",File.join("app/views",@controller_path,"form.html.erb")
      m.template "index.html.erb",File.join("app/views",@controller_path,"index.html.erb")
      m.template "show.html.erb",File.join("app/views",@controller_path,"show.html.erb")
      m.template "model.rb",File.join("app/models","#{file_name}.rb")
      m.template 'unit_test.rb',File.join('test/unit',class_path,"#{@controller_path}_test.rb")
      m.template 'fixtures.yml',File.join('test/fixtures',"#{table_name}.yml")
      m.template 'autocomplete.html.erb',File.join("app/views",@controller_path,"autocomplete.html.erb") if actions.include?("autocomplete")

      # View template for each action.
      actions.without("autocomplete","filter").each do |action|
        path = File.join("app/views",class_path,@controller_path,"#{action}.html.erb")
        m.template "view.html.erb",path,:assigns => {:action => action,:path => path}
      end
    end
  end
end
