module Mp3tagSearch
  class Album
    include MusicInfo

    attr_reader :title, :discs, :thumbnail
  
    def initialize(title, discs, thumbnail)
      @title = title
      @discs = discs
      @thumbnail = thumbnail
    end

    def children
      @discs
    end
  end
end
