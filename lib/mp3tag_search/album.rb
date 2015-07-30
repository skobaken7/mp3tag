module Mp3tagSearch
  class Album
    include MusicInfo

    attr_reader :title, :discs, :thumbnail
  
    def initialize(title, discs, thumbnail)
      @title = title
      @discs = discs.sort_by{|d| d.no}
      @thumbnail = thumbnail
    end

    def children
      @discs
    end

    def track_hash_list
      @discs.map{|disc|
        disc.tracks.map{|track|
          {
            :disc_no => disc.no,
            :track_no => track.no,
            :title => track.title,
            :artist => track.artist,
          }
        }
      }.flatten
    end
  end
end
