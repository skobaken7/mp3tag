require 'yaml'
require 'tempfile'
require 'readline'
require 'mp3info'
require 'open-uri'

module Mp3tag
  module Command
    RENAME_FORMAT = "%genre%/%album_title%/%track_no%-%title%.mp3"
    class Rename
      def initialize(files, parent)
        @files = files

        @parent = parent
        if @parent.nil? || @parent.empty?
          @parent = @files.reduce(:common_prefix)
        end
      end

      def exec
        @files.each{ |filepath| 
          Mp3Info.open(filepath){ |mp3|
            destination_name = get_destination_name(mp3)
            destination_path = File.join(@parent, destination_name)

            FileUtils.mkdir_p(File.dirname(destination_path))
            FileUtils.move(filepath, destination_path)
          }
        }
      end

      def get_destination_name(mp3, format = RENAME_FORMAT)
        predefined_frame_values = PREDEFINED_FRAMES.collect{|key_alias, key|
          [key_alias, mp3.tag2[key]]
        }

        frames_values = predefined_frame_values + mp3.tag2.to_a

        move_to = frames_values.reduce(format){|move_to, frame_pair|
          key, value = frame_pair
          move_to.gsub("%#{key}%", value.to_s)
        }
      end

      def common_prefix(s1, s2)
        i = 0

        while s1[i] == s2[i]
          i += 1
        end

        s1[0, i]
      end
    end
  end
end
