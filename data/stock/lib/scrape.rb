# coding: utf-8
require 'zip'
require 'open-uri'
require 'jpstock'
require 'pp'

#stock = JpStock.price(:code => "4689")
#stocks = JpStock.sector(:id=>"0050")
#pp stocks

module Stock
  def day(date)
    yy = date.strftime("%Y")
    date = date.strftime("%y%m%d")
    path_to_save = File.expand_path("#{__dir__}/../txt/#{yy}/")
    begin 
      file_name = "d#{date}.zip"
      file_url = "http://www.geocities.co.jp/WallStreet-Stock/9256/#{file_name}"
      open(URI.escape(file_url)) do |file|
        Zip::File.open_buffer(file.read) do |zip|
          zip.each do |entry|
            zip.extract(entry, path_to_save + entry.to_s) { true }
            p "Save #{path_to_save+entry.name}"
          end
        end
      end
    rescue
      begin
        file_name = "y#{date}.zip"
        file_url = "http://www.geocities.co.jp/WallStreet-Stock/9256/#{file_name}"
        open(URI.escape(file_url)) do |file|
          Zip::File.open_buffer(file.read) do |zip|
            zip.each do |entry|
              zip.extract(entry, path_to_save + entry.to_s) { true }
              p "Save #{path_to_save+entry.name}"
            end
          end
        end
      rescue
        raise "Specified date file does not exist."
      end
    end
  end

  def test
    p ENV["ROOT"]
  end
  module_function :day
  module_function :test
end

Stock::day(Time.new(2016,2,3))
#Stock::test
