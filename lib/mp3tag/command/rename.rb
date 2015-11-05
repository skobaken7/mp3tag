require 'yaml'
require 'tempfile'
require 'readline'
require 'mp3info'
require 'open-uri'

module Mp3tag
  module Command
    RENAME_FORMAT = "%:genre%/%:album_title%/%:title%.mp3"
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
            move_to = mp3.tag2.reduce(RENAME_FORMAT){|move_to, tag_pair|
              key, value = tag_pair
              move_to.gsub("%{$key}%", value)
            }

            Mp3tag::PREDEFINED_FRAMES.map
          }
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
