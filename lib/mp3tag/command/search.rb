require 'yaml'
require 'tempfile'
require 'readline'
require 'mp3info'
require 'open-uri'

module Mp3tag
  module Command
    class Search
      def initialize(files, interactive = false, query = nil)
        @files = files
        @query = query
        @interactive = interactive

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
        if @interactive
          @query = Readline.readline("query: ", true).to_s.strip
        elsif @query.nil?
          @query = Mp3Info.open(@files[0]){ |mp3|
            mp3.tag2[PREDEFINED_FRAMES[:album_title]]
          }
        end

        candidates = @amazon_client.search_by_keyword(@query)

        index = 0
        if @interactive
          candidates.each_with_index{|c, i|
            puts "#{i+1}: #{c.to_s}"
          }

          index = select_index(1..candidates.size)
        end

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
          :year => album_info.date.year,
          :date => album_info.date.strftime("%m%d"),
          :tracks => Hash[@files.zip(album_info.track_hash_list)]
        }

        if !Mp3tag::edit_tag_proc.nil?
          Mp3tag::edit_tag_proc.call(album_info, default_tags)
        end

        Tempfile::open(Mp3tag.to_s){|f|
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

      def get_tiles_unique(files)
        files.collect{ |filepath| 
        }.uniq
      end
    end
  end
end
