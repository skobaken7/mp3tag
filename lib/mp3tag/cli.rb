require 'thor'

module Mp3tag
  class CLI < Thor
    desc "search [FILE]...", "Search music attributes and set to files"
    def search(*files)
      Mp3tag::Commands::Search.new(files).exec
    end
  end
end
