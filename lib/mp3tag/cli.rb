require 'thor'

module Mp3tag
  class CLI < Thor
    option :interactive, :type => :boolean, :default => false, :aliases => ["i"], :desc => "Search music attributes interactively"
    option :query, :type => :string, :default => nil, :aliases => ["q"], :desc => "Query string to retrieve music attributes"
    desc "search [FILE]...", "Search music attributes and set to files"
    def search(*files)
      begin
        files = Mp3tag.expand_param_files(files)
        
        if files.empty?
          STDERR.puts("no files")
          return
        end

        Mp3tag::Commands::Search.new(files, options["interactive"], options["query"]).exec
      rescue FileNotFoundException
        STDERR.puts("not found file(s)")
      end
    end
    end
  end
end
