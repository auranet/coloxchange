Commands::Plugin.parse!(['install','svn://rubyforge.org/var/svn/acts-as-slug','-x']) unless File.exist?(File.dirname(__FILE__) + "/../acts-as-slug")
puts <<-end_of_engine_install

Sasser Interactive Rails-Base installation complete!
Copyright © #{Date.today.year} Sasser Interactive

end_of_engine_install