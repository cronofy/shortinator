require "bundler/gem_tasks"
require "./lib/shortinator"

namespace :shortinator do
  desc "port links from bitly"
  task :migrate_from_bitly, [:bitly_key, :host] do |t, args|
    require 'open-uri'
    require 'json'

    raise "bitly_key required" unless args.bitly_key
    raise "host required" unless args.host

    records = 50
    page = 0

    while records == 50 do
      json = open("https://api-ssl.bitly.com/v3/user/link_history?access_token=#{args.bitly_key}&offset=#{records * page}") { |r| r.read }

      hash = JSON.parse(json)

      store = Shortinator::Store.new

      records = hash['data']['link_history'].length
      page = page + 1

      puts "#{page} #{records}"

      hash['data']['link_history'].each do |entry|
        id = entry['link'].sub(args.host, '')
        url = entry['long_url']

        begin
          store.insert(id, url)
          # puts "inserted #{id}"
        rescue => e
          # puts "#{id} #{e.message}"
        end
      end
    end
  end
end