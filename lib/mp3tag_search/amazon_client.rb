require 'amazon/ecs'
require 'mp3tag_search/amazon_config'
require 'mp3tag_search/simple_album'

module Mp3tagSearch
  class AmazonClient
    def lookup(asin)
    end

    def search(q, opts)
      resp = Amazon::Ecs.item_search(q, opts)
      resp.items.to_a.select{ |item|
        item.get("ItemAttributes/Binding") == "CD" && item.get("ItemAttributes/Format").nil?
      }.map{ |item|
        asin   = item.get("ASIN")
        title  = item.get("ItemAttributes/Title")
        artist = item.get("ItemAttributes/Artist")
        SimpleAlbum.new(asin, title, artist)
      }
    end

    def search_by_artist(artist)
      search("", default_search_opts.merge(:artist => artist))
    end

    def search_by_keyword(keyword)
      search(keyword, default_search_opts)
    end

    private def default_search_opts
      {
        :country => 'jp',
        :search_index => 'Music',
        :response_group => 'ItemAttributes,Small,Tracks,Images',
      }
    end
  end
end
