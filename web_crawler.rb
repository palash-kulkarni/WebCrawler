require 'open-uri'
require 'nokogiri'
require 'net/http'
require 'csv'
require_relative 'check_gem_availablity.rb'

DEPENDENCIES = %w(nokogiri)

include CheckGemAvailablity

# Class which crawls the webpage, fetches all the links and creates
# a report of all the data about links
class WebCrawler
  attr_accessor :url

  def initialize(url)
    @url = url
  end

  # when status is 200
  # => returns 'Alive'
  # else
  # => returns 'Dead'
  def check_status(status)
    return 'Alive' if status.eql?('200')
    'Dead'
  end

  # execution starts
  def init
    if check_dependencies(DEPENDENCIES)
      host_url = URI.parse(url).host
      process_links(host_url)
    else
      puts 'Please install all Dependencies..!'
    end
  end

  # opens the url, fetches all the links and processes
  def process_links(host_url)
    file = open(url)
    links = Nokogiri::HTML(file).search('a')
    protocol = url.split('://').first
    links = links.map { |link| [link.text.strip, link['href']] }.to_h
    create_report(links, protocol, host_url)
  rescue StandardError => error
    puts "Error Encountered : #{error}"
  end

  # returns 'N/A' if link's name is not available else the name of the link
  def fetch_link_name(link_name)
    return 'N/A' if link_name.empty?
    link_name
  end

  # creates a report of all the links whether those are dead or alive
  def create_report(links, protocol, host_url)
    CSV.open('link_details.csv', 'w+') do |csv|
      links.each do |link_name, link_path|
        insert_record(csv, link_name, link_path, protocol, host_url)
      end
    end
  end

  # creates one record per link, and writes into a CSV file
  def insert_record(csv, link_name, link_path, protocol, host_url)
    url = URI.parse("#{protocol}://#{host_url}#{link_path}")
    response = open(url.to_s)
    result = [] << fetch_link_name(link_name) <<
             "#{protocol}://#{host_url}#{link_path}" <<
             check_status(response.status.first) << response.status.first
    csv << result
  end
end

# takes input url from User
def take_url
  puts 'Please enter the url'
  gets.chomp
end

# created an object of WebCrawler class
web_crawler = WebCrawler.new(take_url)
# called 'init' an instance method of WebCrawler class
web_crawler.init
