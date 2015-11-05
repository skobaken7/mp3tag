require 'thor'

module Mp3tag
  class CLI < Thor
    option :interactive, :type => :boolean, :default => false, :aliases => ["i"], :desc => "Search music attributes interactively"
    option :query, :type => :string, :default => nil, :aliases => ["q"], :desc => "Query string to retrieve music attributes"
    desc "search [FILE]...", "Search music attributes and set to files"
    def search(*files)
      begin
        files = expand_param_files(files)
        
        if files.empty?
          STDERR.puts("No files")
          return
        end

        Mp3tag::Command::Search.new(files, options["interactive"], options["query"]).exec
      rescue FileNotFoundException
        STDERR.puts("Not found file(s)")
      end
    end

    option :parent, :type => :string, :default => nil, :aliases => ["p"], :desc => "Set parent dir of files"
    desc "rename [FILE]...", "Rename and move files by format string"
    def rename(*files)
      begin
        files = expand_param_files(files)
        
        if files.empty?
          STDERR.puts("no files")
          return
        end

        Mp3tag::Command::Rename.new(files, options["parent"]).exec
      rescue FileNotFoundException
        STDERR.puts("not found file(s)")
      end
    end
  
    private 
    def expand_param_files(files)
      files.map{ |file|
        if File::exist?(file)
          if File::directory?(file)
            Dir::glob(File::expand_path("**/*", file))
          else
            file
          end
        else
          raise FileNotFoundException.new
        end
      }.flatten.select{|file|
        file.end_with?(".mp3")
      }.sort
    end
  end
end
