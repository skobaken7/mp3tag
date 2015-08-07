require "mp3tag_search/version"
require "mp3tag_search/music_info"
require "mp3tag_search/amazon_client"
require "mp3tag_search/commands/set_tag"

module Mp3tagSearch
  REQUEST_MAX_COUNT = 100

  def self.edit_tag(&block)
    @edit_tag_proc = block
  end

  def self.edit_tag_proc
    @edit_tag_proc
  end

  require File::expand_path('.mp3tag_search_config', ENV['HOME'])
end

module Amazon
  class Ecs
    class << self
      alias :send_request_sub :send_request
    end

    def self.send_request(opts, cnt = Mp3tagSearch::REQUEST_MAX_COUNT)
      begin
        send_request_sub(opts)
      rescue => e
        if cnt > 0 
          send_request(opts, cnt - 1)
        else
          raise e
        end
      end
    end
  end
end
