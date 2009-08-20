module Engines::RailsExtensions::Routing
  def from_plugin(name)
    map = self
    routes_path = Engines.plugins[name].routes_path
    eval(IO.read(routes_path), binding, routes_path) if File.file?(routes_path)
  end
end

module ::ActionController
  module Routing
    class RouteSet
      class Mapper
        include Engines::RailsExtensions::Routing
      end
    end
  end
end
