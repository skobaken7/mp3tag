require 'thor'

module Mp3tag
  class CLI < Thor
    option :interactive, :type => :boolean, :default => false, :aliases => ["i"], :desc => "search music attributes interactively"
    option :query, :type => :string, :default => nil, :aliases => ["q"], :desc => "query string to retrieve music attributes"
    desc "search [FILE]...", "Search music attributes and set to files"
    def search(*files)
      Mp3tag::Commands::Search.new(files, options["interactive"], options["query"]).exec
    end
  end
end
