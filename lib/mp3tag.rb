require "mp3tag/version"
require "mp3tag/music_info"
require "mp3tag/amazon_client"
require "mp3tag/cli"
require "mp3tag/file_not_found_exception"
require "mp3tag/command"

module Mp3tag
  REQUEST_MAX_COUNT = 10

  def self.edit_tag(&block)
    @edit_tag_proc = block
  end

  def self.edit_tag_proc
    @edit_tag_proc
  end

  config_file_path = File.join(ENV['HOME'], '.mp3tag_config')
  if File::exists? config_file_path+".rb"
    require config_file_path
  end
end

module Amazon
  class Ecs
    class << self
      alias :send_request_sub :send_request
    end

    def self.send_request(opts, cnt = Mp3tag::REQUEST_MAX_COUNT)
      begin
        send_request_sub(opts)
      rescue => e
        if cnt > 0 && not(e.message.include? 403)
          send_request(opts, cnt - 1)
        else
          raise e
        end
      end
    end
  end
end
