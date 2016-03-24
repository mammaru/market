require 'open-uri'
require 'nokogiri'

class Spider
  attr_reader :base_url
  attr_reader :publisher
  attr_reader :number
  @@number = 0
  
  def initialize
    @@number += 1
  end

  def Spider.subclasses
    ObjectSpace.each_object(singleton_class).select{|klass| klass.superclass == self}
  end

  def crawl(url)
    begin
      html = open(url, :proxy => 'http://localhost:5432')
    rescue OpenURI::HTTPError
      return
    end
    Nokogiri::HTML(html.read, nil, 'utf-8')
  end
  
  def scrape
    raise "Error: Method scrape has not been defined yet. Please define scrape method before make instance"
  end
  
end
