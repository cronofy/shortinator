require "shortinator/version"
require_relative 'shortinator/store'
require 'base62'
require 'ostruct'

module Shortinator

  def self.shorten(url, tag=nil)
    raise ArgumentError.new("Shortinator.host not set") unless host
    id = store.add(url, tag)
    "#{host.chop("/")}/#{id}"
  end

  def self.click(id, ip_address)
    unless link = store.get(id)
      raise ArgumentError.new("#{id} not recognised")
    end

    store.track(id, Time.now.utc, ip_address)
    link.url
  end

  def self.store
    @_store ||= Shortinator::Store.new
  end

  def self.store_url
    @_store_url ||= ENV['SHORTINATOR_STORE_URL']
  end

  def self.store_url=(value)
    @_store_url = value
  end

  def self.host
    @_host ||= ENV['SHORTINATOR_HOST']
  end

  def self.host=(value)
    @_host = value
  end

end
