require 'amazon/ecs'
require 'mp3tag_search/simple_album'
require 'mp3tag_search/track'
require 'mp3tag_search/disc'
require 'mp3tag_search/album'
require 'open-uri'

module Mp3tagSearch
  class AmazonClient
    require File::expand_path('.amazon_config', ENV['HOME'])

    COUNTRY_CODE = 'jp'

    def lookup(asin)
      resp = Amazon::Ecs.item_lookup(asin, :country => COUNTRY_CODE, :response_group => 'ItemAttributes,Small,Tracks,Images')

      if resp.has_error?
        return nil
      end

      item = resp.items.first

      detail_page_url = item.get('DetailPageURL')
      detail_description = Nokogiri::HTML(open(detail_page_url)).css("#productDescription").inner_html

      title = item.get("ItemAttributes/Title")
      artist = item.get("ItemAttributes/Artist")
      thumbnail = item.get("MediumImage/URL")

      discs = item.get_elements("Tracks/Disc").map{|disc_elem|
        disc_no = disc_elem.attributes["Number"].text.to_i

        tracks = disc_elem.get_elements("Track").map{|track_elem|
          track_no = track_elem.attributes["Number"].text.to_i
          track_title = track_elem.get
          track_artist = grepArtistFromDescription(detail_description, track_no, track_title)

          Track.new(track_no, track_artist, track_title)
        }.sort_by{|track| 
          track.no
        }

        #set album artist to track artist when all artists are set to unkown
        track_artist_set = tracks.map{|t| t.artist}.uniq
        if track_artist_set.size == 1 && track_artist_set.first == MusicInfo::UNKNOWN
          tracks = tracks.map{|t| t.replace_artist(artist)}
        end

        Disc.new(disc_no, tracks)
      }.sort_by{|disc|
        disc.no
      }

      Album.new(title, discs, thumbnail)
    end

    def grepArtistFromDescription(description, track_no, title)
      lines = description.split("<br").map{|a| a.split("\n")}.flatten
      regexp = /0?#{track_no}\s+(\S+)\s+\/\s+#{title}/

      for l in lines
        if regexp.match(l)
          return $1
        end
      end

      return MusicInfo::UNKNOWN
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
