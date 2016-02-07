# coding: utf-8
require 'active_record'
require 'yaml'
require 'logger'

ROOT = ENV["ROOT"]

namespace :stock do

  task :environment do
    p ENV["ROOT"]
    MIGRATIONS_DIR = "#{ROOT}/migrate"
    SOURCE = "stock"
  end

  task :configuration => :environment do
    @dbconfig = YAML::load(File.open("#{ROOT}/data/config.yml"))[SOURCE]
  end

  task :configure_connection => :configuration do
    ActiveRecord::Base.establish_connection(@dbconfig)
    ActiveRecord::Base.logger = Logger.new("#{ROOT}/log/migration.log")
  end

  desc "Migrate database by script in db/migrate"
  task :migrate => :configure_connection do
    ActiveRecord::Migrator.migrate(MIGRATIONS_DIR, ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  desc "Roll back database schema to the previous version"
  task :rollback => :configure_connection do
    ActiveRecord::Migrator.rollback(MIGRATIONS_DIR, ENV["STEP"] ? ENV["STEP"].to_i : 1)
  end

  desc "Drop database"
  task :drop => :configure_connection do
    db_name = @dbconfig["database"]
    puts "Drop #{db_name}"
    ActiveRecord::Base.connection.drop_database db_name
  end

  desc "Retrieves the current schema version number"
  task :version => :configure_connection do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  desc "Store initial data for table autonomies"
  task :seed => :configure_connection do
    require './lib/models.rb'
    Autonomy.delete_all
    File.open("db/autonomies.ini") do |file|
      file.each_line do |autonomy|
        Autonomy.create(:name => autonomy.force_encoding("utf-8").chomp)
      end
    end
  end

end
