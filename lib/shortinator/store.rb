require 'mongo'

module Shortinator
  class Store

    MONGO_DUPLICATE_KEY_ERROR_CODE = 11000
    MAX_RANDOM = (62 ** 7) -1

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
      raise ArgumentError.new("Shortinator.mongo_url not set") unless Shortinator.mongo_url
      Mongo::MongoClient.from_uri(Shortinator.mongo_url)
    end

    def ensure_indexes
      collection.ensure_index([['id', Mongo::ASCENDING]], { :unique => true })
      collection.ensure_index([['url', Mongo::ASCENDING]], { :unique => true })
      collection.ensure_index([['tag', Mongo::ASCENDING]])
    end

    def add(url, tag=nil)
      doc = {
        'id' => generate_id,
        'url' => url,
        'click_count' => 0,
        'clicks' => []
      }
      doc['tag'] = tag if tag

      collection.insert(doc)

      doc['id']

    rescue Mongo::OperationFailure => e
      if e.error_code == MONGO_DUPLICATE_KEY_ERROR_CODE
        return collection.find_one('url' => url)['id']
      end
      raise
    end

    def get(id)
      if item = collection.find_one('id' => id)
        OpenStruct.new(item)
      end
    end

    def track(id, at, ip_address)
      query = { 'id' => id }
      doc = {
        '$inc' => { 'click_count' => 1 },
        '$push' => { 'clicks' => {
          'ip_address' => ip_address,
          'at' => at
         }
        }
      }
      collection.update(query, doc)
    end

    class DuplicateIdError < StandardError

    end
  end
end