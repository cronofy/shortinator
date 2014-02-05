require 'rubygems'
require 'bundler/setup'
require 'ostruct'
require 'shortinator' # and any other gems you need

include Shortinator

Shortinator.store_url = "mongodb://localhost:27017/shortinator_test"

RSpec.configure do |config|
  # some (optional) config here
end

def random_string
  (0...24).map{ ('a'..'z').to_a[rand(26)] }.join
end