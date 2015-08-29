module Mp3tag
  class Album
    include MusicInfo

    attr_reader :title, :discs, :thumbnail, :date
  
    def initialize(title, discs, thumbnail, date)
      @title = title
      @discs = discs.sort_by{|d| d.no}
      @thumbnail = thumbnail
      @date = date
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
