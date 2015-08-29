module Mp3tag
  class Track
    include MusicInfo

    attr_reader :no, :artist, :title
  
    def initialize(no, artist, title)
      @no = no
      @artist = artist
      @title = title
    end
  
    def to_s
      @title
    end

    def replace_artist(artist)
      Track.new(@no, artist, @title)
    end
  end
end
