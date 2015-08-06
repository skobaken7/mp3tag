require "mp3tag_search/version"
require "mp3tag_search/music_info"
require "mp3tag_search/amazon_client"
require "mp3tag_search/commands/set_tag"

module Mp3tagSearch
  def self.edit_tag(&block)
    @edit_tag_proc = block
  end

  def self.edit_tag_proc
    @edit_tag_proc
  end

  require File::expand_path('.mp3tag_search_config', ENV['HOME'])
end
