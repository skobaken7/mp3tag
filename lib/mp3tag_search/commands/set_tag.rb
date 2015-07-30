require 'yaml'
require 'tempfile'
require 'readline'
require 'mp3info'
require 'open-uri'

module Mp3tagSearch
  module Commands
    class SetTag
      PREDEFINED_FRAMES = {
        :album_title => "TALB",
        :title => "TIT2",
        :artist => "TPE1",
        :genre => "TCON",
        :thumbnail => "APIC",
        :disc_no => "TPOS",
        :track_no => "TRCK"
      }

      FRAME_THUMBNAIL = "APIC"

      def initialize(options)
        @files = options.map{ |file|
          if File::exist?(file)
            if File::directory?(file)
              Dir::glob(File::expand_path("**/*", file))
            else
              file
            end
          else
            STDERR.puts("not exist file or dir")
            exit
          end
        }.flatten.select{|file|
          file.end_with?(".mp3")
        }.sort

        if @files.empty?
          STDERR.puts("no files")
          exit
        end

        @amazon_client = AmazonClient.new

        @thumnail_cache = {}
      end

      def exec
        target = get_target

        album_info = @amazon_client.lookup(target.asin)

        tags = construct_tags(album_info)

        tagging(tags)
      end

      def select_index(range)
        print "input [#{range.first}-#{range.last}|c](1): "
        choice = STDIN.gets.to_s.strip

        if choice == "c"
          return nil
        elsif choice.empty?
          return 0
        else
          if range.include?(choice.to_i)
            return choice.to_i - 1
          else
            select_index(range)
          end
        end
      end

      def get_target
        query = Readline.readline("query: ", true).to_s.strip

        candidates = @amazon_client.search_by_keyword(query)

        candidates.each_with_index{|c, i|
          puts "#{i+1}: #{c.to_s}"
        }

        index = select_index(1..candidates.size)

        if index.nil?
          get_target
        else
          candidates[index]
        end
      end

      def construct_tags(album_info)
        default_tags = {
          :album_title => album_info.title,
          :thumbnail => album_info.thumbnail,
          :genre => "",
          :tracks => Hash[@files.zip(album_info.track_hash_list)]
        }

        Tempfile::open(Mp3tagSearch.to_s){|f|
          YAML.dump(default_tags, f)
          f.flush

          system("#{ENV['EDITOR']} #{f.path}") 

          f.rewind
          YAML.load(f)
        }
      end

      def tagging(album_tag)
        track_tags = album_tag.delete(:tracks)

        track_tags.each{ |filepath, track_tag| 
          track_tag = album_tag.merge(track_tag)

          Mp3Info.open(filepath){ |mp3|
            track_tag.each{ |frame, value|
              if PREDEFINED_FRAMES.include?(frame)
                frame = PREDEFINED_FRAMES[frame]
              end

              if frame == FRAME_THUMBNAIL
                mp3.tag2.remove_pictures
                mp3.tag2.add_picture(get_thumbnail(value))
              else
                mp3.tag2[frame] = value
              end
            }
          }
        }
      end

      def get_thumbnail(url)
        if @thumnail_cache.include?(url)
          @thumnail_cache[url]
        else
          thumbnail = open(url, "rb"){|con| con.read}
          @thumnail_cache[url] = thumbnail
          thumbnail
        end
      end
    end
  end
end
