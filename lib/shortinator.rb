require "shortinator/version"
require_relative 'shortinator/store'
require 'base62'
require 'ostruct'

module Shortinator

  def self.shorten(url, tag=nil)
    raise ArgumentError.new("Shortinator.host not set") unless host
    id = store.add(url, tag)
    "#{host.chomp("/")}/#{id}"
  end

  def self.click(id, params)
    raise ArgumentError.new("#{id} not recognised") unless link = store.get(id)

    store.track(id, Time.now.utc, params)
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
