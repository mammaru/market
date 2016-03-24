# coding: utf-8
require 'zipruby'
require 'open-uri'
require 'date'
require 'yaml'


module Stock
  
  def day(date)
    y = date.strftime("%Y")
    yymmdd = date.strftime("%y%m%d")
    path_to_save = File.expand_path("#{__dir__}/../txt/#{y}")+"/"

    # Create directory if not exist
    FileUtils.mkdir_p(path_to_save) unless FileTest.exist?(path_to_save)

    # Download and load data
    if Date.parse(date.strftime("%Y-%m-%d")).wday==0
      puts "Skip: #{date.strftime("%Y-%m-%d")} was sunday"
      return nil
    elsif Date.parse(date.strftime("%Y-%m-%d")).wday==6
      puts "Skip: #{date.strftime("%Y-%m-%d")} was saturday"
      return nil
    elsif file_path = Dir.glob("#{path_to_save}**#{yymmdd}.txt")[0]
      puts "Load #{file_path}"
    elsif zip_path = Dir.glob("#{path_to_save}**#{yymmdd}.zip")[0]
      puts "Unzip #{zip_path}"
      file_path = unzip(zip_path, path_to_save)
    else
      begin
        zip_name = "d#{yymmdd}.zip"
        zip_path = "http://www.geocities.co.jp/WallStreet-Stock/9256/#{zip_name}"
        sleep(3)
        file_path = unzip(zip_path, path_to_save)
      rescue
        begin
          zip_name = "y#{yymmdd}.zip"
          zip_path = "http://www.geocities.co.jp/WallStreet-Stock/9256/#{zip_name}"
          sleep(3)
          file_path = unzip(zip_path, path_to_save)
        rescue
          puts "Skip: #{date.strftime("%Y-%m-%d")} is holiday or has not been uploaded yet"
          return nil
        end
        puts "Download from #{zip_path}"
      end
    end

    file = open(file_path)
    
    # get date
    ymd = file.gets.encode("utf-8", "Shift_JIS", :universal_newline => true).chomp
    #puts date = Time.new(ymd[0..3], ymd[4..5], ymd[6..7])
    
    stocks = {:date => date, :values => []}    
    keys = [:code, :name, :open, :high, :low, :close, :volume]
    file.each_line do |line|
      values = line.encode("utf-8", "Shift_JIS", :universal_newline => true, :invalid => :replace).chomp.split("\t")
      #values = line.sub("\r", "").force_encoding("utf-8").chomp.split("\t")
      ary = [keys, values].transpose     
      stocks[:values].push(Hash[*ary.flatten])
    end
    file.close
    puts "Success: #{date.strftime("%Y-%m-%d")}"
    return stocks
  end

  private
  def self.unzip(zip_path, save_path)
    file_path = ""
    open(URI.escape(zip_path)) do |f|
      Zip::Archive.open_buffer(f.read) do |zip|
        zip.each do |entry|
          file_name = entry.name
          file_path = save_path + file_name
          open(file_path, 'wb') do |ff|
            ff << entry.read
          end
        end
      end
    end
    file_path
  end

  module_function :day

end
