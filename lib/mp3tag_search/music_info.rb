module Mp3tagSearch
  module MusicInfo
    VARIOUS_ARTISTS = "VariousArtists"
    UNKNOWN = "Unkown"
  
    def children 
      nil
    end
  
    def artist
      if children.nil?
        UNKNOWN
      else
        artists = children.map{|a| a.artist}.uniq
        if artists.size == 0
          UNKNOWN
        elsif artists.size == 1
          artists[0]
        else
          VARIOUS_ARTISTS
        end
      end
    end
  end
end
