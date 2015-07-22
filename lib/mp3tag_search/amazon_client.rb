require 'amazon/ecs'
require 'mp3tag_search/amazon_config'
require 'mp3tag_search/simple_album'

module Mp3tagSearch
  class AmazonClient
    COUNTRY_CODE = 'jp'

    def lookup(asin)
    end

    def search(q, opts = {})
      opts = {
        :country => COUNTRY_CODE,
        :search_index => 'Music',
        :response_group => 'ItemAttributes',
        :count => 25
      }.merge(opts)

      resp = Amazon::Ecs.item_search(q, opts)
      
      resp.items.to_a.select{ |item|
        item.get("ItemAttributes/Binding") == "CD"
      }.map{ |item|
        asin   = item.get("ASIN")
        title  = item.get("ItemAttributes/Title")
        artist = item.get("ItemAttributes/Artist")
        SimpleAlbum.new(asin, title, artist)
      }
    end

    def search_by_artist(artist)
      search("", :artist => artist)
    end

    def search_by_keyword(keyword)
      search(keyword)
    end
  end
end
