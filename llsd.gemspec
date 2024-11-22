lib = File.expand_path('lib', __dir__)
$:.unshift lib unless $:.include? lib
require 'llsd/version'

Gem::Specification.new do |s|
  s.name = 'llsd'
  s.version = LLSD::VERSION
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'An updated implementation of LLSD (Linden lab Structured Data) in Ruby'
  s.description = 'A Ruby library for parsing and generating LLSD (Linden Lab Structured Data) XML format, updated for modern Ruby versions.'
  s.homepage = 'https://github.com/earlbalai/llsd'
  s.email = 'earl@kapulabs.com'
  s.authors = ['Beck Linden', 'Joshua Linden', 'Earl Balai']

  # Add license
  s.license = 'MIT'

  # Specify minimum Ruby version
  s.required_ruby_version = '>= 3.0.0'

  # Files to include
  s.files = %w[LICENSE Rakefile]
  s.files += Dir['lib/**/*']
  s.files += Dir['test/**/*']

  # Add dependencies if any
  s.add_dependency 'rexml', '~> 3.2'

  # Add development dependencies
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rake', '~> 13.0'

  # Metadata
  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/earlbalai/llsd/issues',
    'changelog_uri' => 'https://github.com/earlbalai/llsd/blob/main/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/earlbalai/llsd'
  }
end
