require 'mongo'
require 'base62'

module Shortinator
  class Store

    ShortenedLink = Struct.new(:id, :url, :created_at, :click_count, :clicks, :tag)

    KEY_LENGTH = 7
    MAX_KEY_VALUE = (62 ** KEY_LENGTH) - 1
    KEY_OFFSET = 62 ** (KEY_LENGTH - 1)

    def generate_id
      begin
        id = (SecureRandom.random_number(MAX_KEY_VALUE - KEY_OFFSET) + KEY_OFFSET).base62_encode
      end while id_exists?(id)
      id
    end

    def collection
      @_collection ||= begin
        @_collection = client['shortinator_urls']
        ensure_indexes
        @_collection
      end
    end

    def client
      Shortinator.store_configured!
      Mongo::Client.new(Shortinator.store_url)
    end

    def ensure_indexes
      collection.indexes.create_many([
        { :key => { id: 1 }, :unique => true },
        { :key => { url: 1 }},
      ])
    end

    def add(url, tags={})
      unless doc = collection.find({ 'url' => url }).first
        doc = new_doc(generate_id, url, Time.now.utc, tags)
        collection.insert_one(doc)
      end
      doc['id']
    end

    def insert(id, url, created_at=Time.now.utc, tags={})
      collection.insert_one(new_doc(id, url, created_at, tags))
    end

    def new_doc(id, url, created_at=Time.now.utc, tags={})
      {
        'id' => id,
        'url' => url,
        'created_at' => created_at,
        'click_count' => 0,
        'clicks' => [],
        'tags' => tags
      }
    end

    def id_exists?(id)
      collection.find({ 'id' => id } , { :fields => { :_id => 1 } }).limit(1).count() > 0
    end

    def get(id)
      if item = collection.find('id' => id).first
        ShortenedLink.new(item['id'], item['url'], item['created_at'], item['click_count'], item['clicks'], item['tags'])
      end
    end

    def track(id, at, params={})
      query = { 'id' => id }
      doc = {
        '$inc' => { 'click_count' => 1 },
        '$push' => { 'clicks' => params.merge({ 'at' => at}) }
      }
      collection.update_one(query, doc)
    end
  end
end
