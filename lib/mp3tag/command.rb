require 'mp3tag/command/search'
require 'mp3tag/command/rename'

module Mp3tag
  module Command
    PREDEFINED_FRAMES = {
      :album_title => "TALB",
      :title => "TIT2",
      :artist => "TPE1",
      :genre => "TCON",
      :thumbnail => "APIC",
      :disc_no => "TPOS",
      :track_no => "TRCK",
      :year => 'TYER',
      :date => 'TDAT'
    }

    FRAME_THUMBNAIL = "APIC"
  end
end
