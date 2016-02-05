# coding: utf-8
#require 'fileutils'
#require 'rexml/document'
#require 'json'

# loading files in lib/
ENV["ROOT"] = File.expand_path("..", __FILE__)
ENV["ENV"] = "development"
$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'io.rb'


db = DataBase.instance
db.save_from_xml("ignore/tweet.xml")
users = db.users
tweets = db.tweets
autonomies = db.autonomies
tweets.each do |tweet|
  #p tweet.id
  #p tweet.user.name
  p tweet.text
  #p tweet.tweeted_at
end

puts "\n============"

users.each do |user|
  p user.name
  user.tweets.each do |tweet|
    p tweet.text
  end
  puts "-----"
end

puts "\n============"

autonomies.each do |autonomy|
  p autonomy.name
  autonomy.tweets.each do |tweet|
    p tweet.text
  end
  puts "-----"
end
