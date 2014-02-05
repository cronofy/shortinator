require "shortinator/version"
require_relative 'shortinator/store'

module Shortinator

  MAX_RANDOM = (62 ** 7) -1

  def self.generate_id
    SecureRandom.random_number(MAX_RANDOM).base62_encode
  end

  def self.shorten(url)

  end

  def self.mongo_url
    @_mongo_url ||= ENV['SHORTINATOR_MONGO_URL']
  end

  def self.mongo_url=(value)
    @_mongo_url = value
  end

end
