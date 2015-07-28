# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mp3tag_search/version'

Gem::Specification.new do |spec|
  spec.name          = "mp3tag_search"
  spec.version       = Mp3tagSearch::VERSION
  spec.authors       = ["skobaken"]
  spec.email         = ["skobaken@gmail.com"]

  spec.summary       = "command to search music information from amazon and edit mp3 tag"
  spec.description   = "command to search music information from amazon and edit mp3 tag"
  spec.homepage      = ""

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ""
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"

  spec.add_dependency "amazon-ecs"
  spec.add_dependency "ruby-mp3info"
end
