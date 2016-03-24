# coding: utf-8
require 'date'

Dir["#{LIB_PATH}/**/*.rb"].each do |path|
  require path
end

namespace :stock do
  
  task :configuration do
    @mig_dir = "#{LIB_PATH}/io/migrate"
    @db_config = CONFIG["db"]
    @log_path = "#{LOG_DIR}/stock.log"
  end
  
  task :connection => :configuration do
    DB = DataBase.new([@db_config, @log_path, @mig_dir])
  end
  
  desc "Migrate database"
  task :migrate => :connection do
    DB.migrate(ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end
  
  desc "Roll back database schema to the previous version"
  task :rollback => :connection do
    DB.rollback(ENV["STEP"] ? ENV["STEP"].to_i : 1)
  end
  
  desc "Drop database"
  task :drop => :connection do
    DB.drop
  end
  
  desc "Retrieves the current schema version number"
  task :version => :connection do
    DB.version
  end
  
  desc "Update recent stocks"
  task :update => :connection do
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
  
  namespace :daily do
    desc "Store daily values"
    task :values_of => :connection do
      date = Date.parse(ENV["DATE"].to_s)
      if date.strftime("%Y")==@year.to_s
        if daily_stocks = Stock::day(date)
          DB.store(daily_stocks)
        end
      else
        raise "setting of year in config.yml must be #{date.strftime("%Y")}"
      end
    end

    desc "Store annual data"
    task :store => :connection do
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

