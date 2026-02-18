$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "sequence_generator/version"

# 🚨 Run tests before building the gem
if $PROGRAM_NAME.end_with?("gem") # only when running `gem build`
  puts "👉 Running tests before building gem..."
  unless system("bundle exec rake test")
    abort("❌ Tests failed! Aborting gem build.")
  end
end

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "sequence_generator"
  spec.version     = SequenceGenerator::VERSION
  spec.authors     = ["Prasann Shah"]
  spec.email       = ["prasann@shipmnts.com"]
  spec.homepage    = "https://github.com/shipmnts/sequence_generator"
  spec.summary     = "Generate sequences formatted as a string for the users"
  spec.description = "Formatted sequence for rails models with unique scope"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 7.0"

  spec.add_development_dependency "sqlite3"
end
