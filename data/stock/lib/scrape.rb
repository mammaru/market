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
    y = date.strftime("%Y")
    yymmdd = date.strftime("%y%m%d")
    path_to_save = File.expand_path("#{__dir__}/../txt/#{y}")+"/"

    #Create directory if not exist
    FileUtils.mkdir_p(path_to_save) unless FileTest.exist?(path_to_save)
    
    if file_path = Dir.glob("#{path_to_save}**#{yymmdd}.txt")[0]
      p "Load #{file_path}"
    elsif zip_path = Dir.glob("#{path_to_save}**#{yymmdd}.zip")[0]
      file_path = unzip(zip_path, path_to_save)
    else
      begin 
        zip_name = "d#{yymmdd}.zip"
        #zip_path = "http://www.geocities.co.jp/WallStreet-Stock/9256/#{zip_name}"
        file_path = unzip(zip_path, path_to_save)
        #open(URI.escape(file_url)) do |f|
          #Zip::File.open_buffer(f.read) do |zip|
            #zip.each do |entry|
              #zip.extract(entry, path_to_save+entry.name) { true }
              #file_txt = entry.name
              #p "Save #{path_to_save+entry.name}"
            #end
          #end
        #end
      rescue
        begin
          zip_name = "y#{yymmdd}.zip"
          #zip_path = "http://www.geocities.co.jp/WallStreet-Stock/9256/#{zip_name}"
          zip_path = Dir.glob(path_to_save+zip_name)[0]
          file_path = unzip(zip_path, path_to_save)
          #open(URI.escape(file_url)) do |f|
            #Zip::File.open_buffer(f.read) do |zip|
              #zip.each do |entry|
                #p entry.to_s, entry.name
                #zip.extract(entry, path_to_save+entry.name) { true }
                #file_txt = entry.name
                #p "Save #{path_to_save+entry.name}"
              #end
            #end
          #end
        rescue
          p "#{date.strftime("%Y-%m-%d")} is holiday."
          return nil
        end
      end
    end

    file = open(file_path)   
    # get date
    ymd = file.gets.encode("utf-8", "Shift_JIS").chomp
    p date = Time.new(ymd[0..3], ymd[4..5], ymd[6..7])
    stocks = {:date => date, :values => []}
    
    keys = [:code, :name, "open", "high", "low", "close", "volume"]
    file.each_line do |line|
      values = line.encode("utf-8", "Shift_JIS").chomp.split("\t")
      ary = [keys,values].transpose     
      stocks[:values].push(Hash[*ary.flatten])
    end
    file.close
    p stocks[:values][0]
    return stocks
  end

  private
  def unzip(zip_path, save_path)
    begin
      open(URI.escape(zip_path)) do |f|
        Zip::File.open_buffer(f.read) do |zip|
          zip.each do |entry|
            file_name = entry.name
            file_path = save_path+file_name
            zip.extract(entry, file_path) { true }
            p "Save #{path_to_save+entry.name}"
          end
        end
      end
    rescue
      raise
    end
    file_path
  end
  
  module_function :day

end

Stock::day(Time.new(2016,2,2))
#Stock::test
