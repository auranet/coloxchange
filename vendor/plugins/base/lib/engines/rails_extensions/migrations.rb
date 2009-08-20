require "engines/plugin/migrator"
module Engines::RailsExtensions::Migrations
  def self.included(base)
    base.class_eval { alias_method_chain :initialize_schema_information, :engine_additions }
  end

  def initialize_schema_information_with_engine_additions
    initialize_schema_information_without_engine_additions
    begin
      execute <<-ESQL
      CREATE TABLE #{Engines::Plugin::Migrator.schema_info_table_name}  (plugin_name #{type_to_sql(:string)}, version #{type_to_sql(:integer)})
ESQL
    rescue ActiveRecord::StatementInvalid
    end
  end
end

module ::ActiveRecord
  module ConnectionAdapters
    module SchemaStatements
      include Engines::RailsExtensions::Migrations
    end
  end
end

::ActiveRecord::SchemaDumper.ignore_tables << Engines.schema_info_table