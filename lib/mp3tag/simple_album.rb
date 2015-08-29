module Mp3tag
  class SimpleAlbum
    include MusicInfo

    attr_reader :asin, :title, :artist

    def initialize(asin, title, artist)
      @asin = asin
      @title = title
      @artist = artist
    end

    def artist
      @artist
    end

    def to_s 
      "#{@title} / #{@artist}"
    end
  end
end
