# coding: utf-8
require 'active_record'
require 'yaml'
require 'logger'

ROOT = __dir__
Dir["#{ROOT}/lib/*.rb"].each do |path|
  require path
end
#require "#{ROOT}/lib/models.rb"

namespace :db do

  task :environment do
    p ENV["ROOT"]
    MIGRATIONS_DIR = "#{ROOT}/migrate"
    CONFIG = "#{ROOT}/config.yml"
    LOG = "#{ROOT}/log/database.log"
  end

  task :configuration => :environment do
    @dbconfig = YAML::load(File.open(CONFIG))["db"]
  end

  task :configure_connection => :configuration do
    ActiveRecord::Base.establish_connection(@dbconfig)
    ActiveRecord::Base.logger = Logger.new(LOG)
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
  task :drop, ["year"] => :configure_connection do |task, args|
    p task
    p args.year
    db_name = "#{args.year}.sqlite3"
    puts "Drop #{db_name}"
    ActiveRecord::Base.connection.drop_database db_name
  end

  desc "Retrieves the current schema version number"
  task :version => :configure_connection do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  desc "Store annual data from txt files"
  task :store, ["year"] => :configure_connection do |task, args|
    #require './lib/models.rb'
    dir = Dir.open("#{ROOT}/txt/#{ENV["YEAR"]}/")
    dir.each do |f|
      if File.extname(f) == ".txt"
        file = open("#{ROOT}/txt/#{ENV["YEAR"]}/#{f}")
        ymd = file.gets.encode("utf-8", "Shift_JIS").chomp
        yy, mm, dd = ymd[0..3], ymd[4..5], ymd[6..7]
        puts date = Time.new(yy,mm,dd).strftime("%Y-%m-%d")
        unless d = Dating.find_by_date(date)
          d = Dating.create(:date => date)
        end
        file.each_line do |stock|
          code, name, open, high, low, close, volume = stock.encode("utf-8", "Shift_JIS").chomp.split("\t")
          unless n = Name.find_by_code(code)
            Name.create(:code => code, :name => name)
          end
          Price.create(:code => code,
                       :dating_id => d.id,
                       :open => open,
                       :high => high,
                       :low => low,
                       :close => close,
                       :volume => volume)
        end
        file.close
      end
    end
  end

end
