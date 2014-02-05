require 'mongo'

module Shortinator
  class Store

    MONGO_DUPLICATE_KEY_ERROR_CODE = 11000

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
      collection.ensure_index([['tag', Mongo::ASCENDING]])
    end

    def add(id, url, tag=nil)
      doc = {
        'id' => id,
        'url' => url,
        'click_count' => 0,
        'clicks' => []
      }
      doc['tag'] = tag if tag

      collection.insert(doc)

    rescue Mongo::OperationFailure => e
      raise DuplicateIdError.new("#{id} already in use") if e.error_code == MONGO_DUPLICATE_KEY_ERROR_CODE
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