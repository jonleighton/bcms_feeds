# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "bcms_feeds"
    gemspec.summary = "Feeds in BrowserCMS"
    gemspec.description = "A BrowserCMS module which fetches, caches and displays RSS/Atom feeds"
    gemspec.email = "j@jonathanleighton.com"
    gemspec.homepage = "http://github.com/jonleighton/bcms_feeds"
    gemspec.description = "TODO"
    gemspec.authors = ["Jon Leighton"]
    gemspec.files += Dir["app/**/*"]
    gemspec.files += Dir["db/migrate/*.rb"]
    gemspec.files -= Dir["db/migrate/*_browsercms_*.rb"]
    gemspec.files -= Dir["db/migrate/*_load_seed_data.rb"]
    gemspec.files += Dir["lib/bcms_feeds.rb"]
    gemspec.files += Dir["rails/init.rb"]
    gemspec.add_dependency('simple-rss')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

