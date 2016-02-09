# coding: utf-8
require 'yaml'
require 'date'

ROOT = __dir__
Dir["#{ROOT}/lib/*.rb"].each do |path|
  require path
end

namespace :stock do

  task :environment do
    CONFIG_YAML = "#{ROOT}/config.yml"
    MIGRATION_DIR = "#{ROOT}/migrate"
    LOG_DIR = "#{ROOT}/log"
  end

  namespace :daily do
    task :configuration => :environment do
      yml = YAML::load(File.open(CONFIG_YAML))
      @year = yml["year"]
      @dbconfig = yml["db"]

      @daily_config = @dbconfig["daily"]
      @daily_config["database"] = "#{ROOT}/db/daily/#{@year}.sqlite3"
      @daily_log = "#{LOG_DIR}/daily.log"
    end

    task :configure_connection => :configuration do
      DB = DataBase.new([@daily_config, @daily_log, MIGRATION_DIR])
    end

    desc "Migrate database"
    task :migrate => :configure_connection do
      DB.migrate(ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end

    desc "Roll back database schema to the previous version"
    task :rollback => :configure_connection do
      DB.rollback(ENV["STEP"] ? ENV["STEP"].to_i : 1)
    end

    desc "Drop database"
    task :drop => :configure_connection do
      DB.drop
    end

    desc "Retrieves the current schema version number"
    task :version => :configure_connection do
      DB.version
    end

    desc "Store daily values"
    task :values_of => :configure_connection do
      date = Date.parse(ENV["DATE"].to_s)
      if date.strftime("%Y")==@year.to_s
        if daily_stocks = Stock::day(date)
          DB.store(daily_stocks)
        end
      else
        raise "setting of year in config.yml must be #{date.strftime("%Y")}"
      end
    end

    desc "Update reacent stocks"
    task :update => :configure_connection do
      from = Date.parse(DB.last_modified.to_s) + 1
      today = Date.today
      if today.strftime("%Y")==@year.to_s
        p "Update stocks from #{from} to #{today}"
        from.upto(today) do |d|
          if daily_stocks = Stock::day(d)
            DB.store(daily_stocks)
          end
        end
      else
        raise "setting of year in config.yml must be #{today.strftime("%Y")}"
      end
    end

    desc "Store annual data"
    task :all => :configure_connection do
      nyd = Date.parse("#{@year}-01-01")
      nye = (Date.parse("#{@year}-12-31")<Date.today) ? Date.parse("#{@year}-12-31") : Date.yesterday
      nyd.upto(nye) do |d|
        if daily_stocks = Stock::day(d)
          DB.store(daily_stocks)
        end
      end
    end
  end

end

  

