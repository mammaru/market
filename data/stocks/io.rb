# coding: utf-8
require 'time'
require 'fileutils'
require 'rexml/document'
#require 'json'
require 'active_record'
require 'yaml'
require 'logger'

# loading files in lib/
$LOAD_PATH << File.expand_path("..", __FILE__) unless $LOAD_PATH.include? File.expand_path("..", __FILE__)
require 'models.rb'


class DataBase
  include Singleton

  def initialize
    @db = "db"
    @env = ENV["ENV"] ? ENV["ENV"] : "development"
    @dbconfig = YAML::load(File.open("#{ENV["ROOT"]}/config/database.yml"))[@db][@env]
    # retrieve or create connection to database
    ActiveRecord::Base.establish_connection(@dbconfig)
    unless  (ActiveRecord::Base.connection.table_exists? "tweets" and
             ActiveRecord::Base.connection.table_exists? "users" and
             ActiveRecord::Base.connection.table_exists? "autonomies") then
      # create database and migrate
      p "execute migration."
      migrt_dir = ENV["ROOT"] + "/db/migrate"
      ActiveRecord::Base.logger = Logger.new("#{ENV["ROOT"]}/db/database.log")
      ActiveRecord::Migrator.migrate(migrt_dir)
    end

    # storing initial data to autonomies
    Autonomy.delete_all
    File.open("#{ENV["ROOT"]}/db/autonomies.ini") do |file|
      file.each_line do |autonomy|
        Autonomy.create(:name => autonomy.force_encoding("utf-8").chomp)
      end
    end
  end

  def tweets
    Tweet.all
  end

  def users
    User.all
  end

  def autonomies
    Autonomy.all
  end

  def save(tw)
    tweets = (tw.instance_of? Hash) ? [tw] : tw
    #p tweets
    begin
      tweets.each do |t|
        # set user
        user_name = t.has_key?(:user_name) ? t[:user_name] : t["user_name"]
        #p user_name
        user = User.find_by_name(user_name)
        #p user
        unless user then # new user
          user = User.new(name: user_name)
          user.save
        end

        tweet = Tweet.new(:user_id => user.id,
                          :text => t.has_key?(:text) ? t[:text] : t["text"],
                          :tweeted_at => t.has_key?(:tweeted_at) ? t[:tweeted_at] : t["tweeted_at"],
                          :latitude => t.has_key?(:latitude) ? t[:latitude] : t["latitude"],
                          :longitude => t.has_key?(:longitude) ? t[:longitude] : t["longitude"],
                          :place => t.has_key?(:place) ? t[:place] : t["place"],
                          :autonomy_id => 1)
        #p tweet
        tweet.save
      end
    rescue
      raise "augument must be a hash or an array that contains hash"
    end
  end

  def save_from_xml(file_path)
    begin
      # load file
      tw_xml = REXML::Document.new(File.new("#{ENV["ROOT"]}/#{file_path}"))
    rescue
      if File.exists? "#{ENV["ROOT"]}/#{file_path}" then
        raise "File has invalid form for xml"
      else
        raise "File does not exist. Augument file_path must be relative path from ENV[\"ROOT\"]."
      end
    end

    tweets = [] # is an array in which each element has single tweet xml object
    tw_xml.elements.each("//xml/list/tweet") do |tw|
      tweets << {:user_name => tw.elements["user"].attributes["name"],
                 :text => tw.elements["text"].attributes["body"],
                 :tweeted_at => Time.parse(tw.attributes["time"]),
                 :latitude => tw.elements["place"].attributes["latitudeF"],
                 :longitude => tw.elements["place"].attributes["longitudeF"],
                 :place => tw.elements["place"].attributes["name"],
                 :autonomy => tw.elements["place"].attributes["name"]}
    end

    self.save(tweets)

  end

  def save_from_json(file_path)
    begin
      # load file
      tw_json = JSON.parse("#{ENV["ROOT"]}/#{file_path}")
    rescue
      if File.exists? "#{ENV["ROOT"]}/#{file_path}" then
        raise "File has invalid form for json"
      else
        raise "File does not exist. Augument file_path must be relative path from ENV[\"ROOT\"]."
      end
    end

    tweets = [] # is an array in which each element has single tweet xml object
    tw_xml.elements.each("//xml/list/tweet") do |tw|
      tweets << {:user_name => tw.elements["user"].attributes["name"],
                 :text => tw.elements["text"].attributes["body"],
                 :tweeted_at => Time.parse(tw.attributes["time"]),
                 :latitude => tw.elements["place"].attributes["latitudeF"],
                 :longitude => tw.elements["place"].attributes["longitudeF"],
                 :place => tw.elements["place"].attributes["name"],
                 :autonomy => tw.elements["place"].attributes["name"]}
    end

    self.save(tweets)

  end

end
