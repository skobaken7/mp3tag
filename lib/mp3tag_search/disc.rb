module Mp3tagSearch
  class Disc
    include MusicInfo

    attr_reader :no, :tracks
  
    def initialize(no, tracks)
      @no = no
      @tracks = tracks.sort_by{|t| t.no}
    end
  
    def children 
      @tracks
    end
  end
end
