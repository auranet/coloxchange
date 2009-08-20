module Engines
  module Assets    
    class << self      
      def initialize_base_public_directory
        dir = Engines.public_directory
        FileUtils.mkdir(dir) unless File.exist?(dir)
      end

      def mirror_files_for(plugin)
        return if plugin.public_directory.nil?
        begin 
          Engines.mirror_files_from(plugin.public_directory, File.join(Engines.public_directory, plugin.name))
        rescue Exception => e
          Engines.logger.warn "WARNING: Couldn't create the public file structure for plugin '#{plugin.name}'; Error follows:"
          Engines.logger.warn e
        end
      end
    end 
  end
end