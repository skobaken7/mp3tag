module Mp3tagSearch
  class SimpleAlbum
    include MusicInfo

    def initialize(asin, title, artist)
      @asin = asin
      @title = title
      @artist = artist
    end

    def artist
      @artist
    end

    def to_s 
      @title
    end
  end
end
