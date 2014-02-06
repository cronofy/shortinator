require_relative "shortinator/version"
require_relative 'shortinator/store'

module Shortinator

  KEY_REGEX = /\A[0-9a-zA-Z]{#{Store::KEY_LENGTH}}\Z/

  def self.shorten(url, tags={})
    raise ArgumentError.new("Shortinator.host not set") unless host
    id = store.add(url, tags)
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
