# coding: utf-8
require 'active_record'
require 'logger'
require 'date'

# loading files in lib/
$LOAD_PATH << File.expand_path("..", __FILE__) unless $LOAD_PATH.include? File.expand_path("..", __FILE__)
require 'models.rb'


class DataBase

  def initialize(args)
    @config, @log_path, @mig_path = args#config, log_path, mig_path
    # retrieve or create connection to database
    ActiveRecord::Base.establish_connection(@config)
    ActiveRecord::Base.logger = Logger.new(@log_path)
    if ActiveRecord::Migrator.current_version < 1
      self.migrate
      p "Execute migration."
    end
  end

  def migrate(version=nil)
    ActiveRecord::Migrator.migrate(@mig_path, version ? version.to_i : nil)
  end

  def rollback(step=1)
    ActiveRecord::Migrator.rollback(@mig_path, step ? step.to_i : 1)
  end

  def drop
    db_name = @config["database"]
    puts "Drop #{db_name}"
    ActiveRecord::Base.connection.drop_database db_name
  end

  def version
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end
  
  def name
    Name.all
  end

  def prices
    Price.all
  end

  def dates
    Dating.all
  end

  def last_modified
    date = Dating.order(:date).last[:date]
    Time.new(date.strftime("%Y"),date.strftime("%m"),date.strftime("%d"))
  end

  def store(daily_stocks)
    date = daily_stocks[:date]
    stocks = daily_stocks[:values]
    unless dating = Dating.find_by_date(date)
      dating = Dating.create(:date => date)
      stocks.each do |stock|
        unless n = Name.find_by_code(stock[:code].to_i)
          Name.create(:code => stock[:code].to_i, :name => stock[:name])
        end
        Price.create(:code => stock[:code].to_i,
                     :dating_id => dating.id,
                     :open => stock[:open].to_i,
                     :high => stock[:high].to_i,
                     :low => stock[:low].to_i,
                     :close => stock[:close].to_i,
                     :volume => stock[:volume].to_f)
      end
    end
  end


end
