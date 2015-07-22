module Mp3tagSearch
  module MusicInfo
    VARIOUTS_ARTISTS = "VariousArtists"
    UNKNOWN = "Unkown"
  
    def children 
      nil
    end
  
    def artist
      if chidren.nil?
        UNKNOWN
      else
        artists = chidren.map{|a| a.artist}.unique
        if artists.size == 0
          UNKNOWN
        elsif artists.size == 1
          artists[0]
        else
          VARIOUTS_ARTISTS
        end
      end
    end
  end
end
