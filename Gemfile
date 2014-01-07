source 'http://ruby.taobao.org'
# source 'https://rubygems.org'

gem 'rails', '3.2.14'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'jquery-rails'
gem 'god'
gem "whenever", :require => false #it's not required in our application directly
gem 'nokogiri'


gem 'cancan'
gem 'will_paginate-bootstrap'

gem "cocaine", "0.3.2"

gem 'sprockets'
gem 'execjs'
gem 'therubyracer'

gem 'bitcoin-ruby', git: 'https://github.com/AlexChien/bitcoin-ruby', branch: 'master', require: 'bitcoin'
gem 'eventmachine'
gem 'sequel'
gem 'sqlite3', :platforms => :ruby, :require => false
gem 'pg', :platforms => :ruby, :require => false
gem "em-dns"

gem 'rest-client', :require => 'restclient'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'

  gem 'compass-rails'
  # front end frameworks
  gem 'compass_twitter_bootstrap'
  gem 'sassy-buttons'
end

group :development, :test do
  gem "rspec"#, "~> 2.7"
  gem "rspec-rails"#, "~> 2.7"
  gem "pry"
  gem 'pry-rails'
end

group :development do
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'capistrano-maintenance'
  gem "capistrano_colors", "~> 0.5.5"
  gem 'capistrano-nginx', :git => "git@github.com:AlexChien/capistrano-nginx.git", :require => false
  gem 'rvm-capistrano'
  gem 'rails-footnotes', '~> 3.7.8'
  gem "factory_girl_rails", "~> 1.4"
  gem "faker"
  gem "bullet"
  gem "magic_encoding"
  gem "thin"
  # A collection of tweaks to improve your Rails (3.1+) development experience.
  gem "rails-dev-tweaks"
end

group :test do
  gem "ruby-debug19"
  gem "yard"

  # speed up rspec
  # http://ruby.railstutorial.org/chapters/static-pages#top
  gem "factory_girl_rails", "~> 1.4"
  gem "faker"
  gem 'rb-readline'
  gem "guard-rspec"
  gem "spork"#, "~> 0.9"
  gem "guard-spork"#, "~> 0.8"
  gem "guard-livereload"
  gem "growl"
  gem "pry"
  gem "pry-nav"
  gem "pry-doc"
  gem "database_cleaner", "0.7.1"

  gem "timecop"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "delorean"
  gem "capybara"
  gem "launchy"
end

group :test, :darwin do
  gem 'rb-fsevent'#, :require => false if RUBY_PLATFORM =~ /darwin/i
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
