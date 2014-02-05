require "shortinator/version"
require_relative 'shortinator/store'
require 'base62'
require 'ostruct'

module Shortinator

  MAX_RANDOM = (62 ** 7) -1

  def self.generate_id
    SecureRandom.random_number(MAX_RANDOM).base62_encode
  end

  def self.shorten(url, tag=nil)
    raise ArgumentError.new("Shortinator.host not set") unless host
    id = generate_id
    store.add(id, url, tag)
    "#{host}/#{id}"
  end

  def self.click(id, ip_address)
    if link = store.get(id)
      store.track(id, Time.now.utc, ip_address)
      link.url
    else
      ArgumentError.new("#{id} not recognised")
    end
  end

  def self.store
    @_store ||= Shortinator::Store.new
  end

  def self.mongo_url
    @_mongo_url ||= ENV['SHORTINATOR_STORE_URL']
  end

  def self.mongo_url=(value)
    @_mongo_url = value
  end

  def self.host
    @_host ||= ENV['SHORTINATOR_HOST']
  end

  def self.host=(value)
    @_host = value
  end

end
