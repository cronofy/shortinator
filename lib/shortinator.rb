require_relative "shortinator/version"
require_relative 'shortinator/store'

module Shortinator

  KEY_REGEX = /\A[0-9a-zA-Z]{#{Store::KEY_LENGTH}}\Z/

  def self.shorten(url, tags={})
    configured!

    id = store.add(url, tags)
    "#{host}/#{id}"
  end

  def self.click(id, params)
    raise ArgumentError.new("#{id} not recognised") unless link = store.get(id)

    store.track(id, Time.now.utc, params)
    link.url
  end

  def configured?
    store_configured? && !!host
  end

  def store_configured?
    !!store_url
  end

  def configured!
    store_configured!
    raise ArgumentError.new('Shortinator not configured!') unless configured?
  end

  def store_configured!
    raise ArgumentError.new('Shortinator store not configured!') unless store_configured?
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
    @_host ||= ENV['SHORTINATOR_HOST'].chomp('/')
  end

  def self.host=(value)
    @_host = value.chomp('/')
  end

end
