require 'mongo'
require 'base62'

module Shortinator
  class Store

    MONGO_DUPLICATE_KEY_ERROR_CODE = 11000
    MAX_RANDOM = (62 ** 7) -1

    ShortenedLink = Struct.new(:id, :url, :created_at, :click_count, :clicks, :tag)

    def generate_id
      SecureRandom.random_number(MAX_RANDOM).base62_encode
    end

    def collection
      @_collection ||= begin
        @_collection = client.db['shortinator_urls']
        ensure_indexes
        @_collection
      end
    end

    def client
      raise ArgumentError.new("Shortinator.store_url not set") unless Shortinator.store_url
      Mongo::MongoClient.from_uri(Shortinator.store_url)
    end

    def ensure_indexes
      collection.ensure_index([['id', Mongo::ASCENDING]], { :unique => true })
      collection.ensure_index([['url', Mongo::ASCENDING]], { :unique => true })
    end

    def add(url, tags=[])
      doc = new_doc(generate_id, url, tags)

      collection.insert(doc)

      doc['id']

    rescue Mongo::OperationFailure => e
      if e.error_code == MONGO_DUPLICATE_KEY_ERROR_CODE
        return collection.find_one('url' => url)['id']
      end
      raise
    end

    def insert(id, url)
      collection.insert(new_doc(id, url, []))
    end

    def new_doc(id, url, tags)
      {
        'id' => id,
        'url' => url,
        'created_at' => Time.now.utc,
        'click_count' => 0,
        'clicks' => [],
        'tags' => tags
      }
    end

    def get(id)
      if item = collection.find_one('id' => id)
        ShortenedLink.new(item['id'], item['url'], item['created_at'], item['click_count'], item['clicks'], item['tags'])
      end
    end

    def track(id, at, params={})
      query = { 'id' => id }
      doc = {
        '$inc' => { 'click_count' => 1 },
        '$push' => { 'clicks' => params.merge({ 'at' => at}) }
      }
      collection.update(query, doc)
    end

    class DuplicateIdError < StandardError

    end
  end
end