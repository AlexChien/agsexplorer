# -*- encoding : utf-8 -*-
set :stages, %w(staging production aws ey180)
set :default_stage, "staging"

require 'capistrano/ext/multistage'
require 'capistrano_colors'
require "bundler/capistrano"

require 'capistrano/maintenance'
# use local template instead of included one with capistrano-maintenance
set :maintenance_template_path, 'app/views/maintenance.html.erb'
# disable the warning on how to configure your server
set :maintenance_config_warning, false

# Load RVM's capistrano plugin.
require "rvm/capistrano"

# nginx capistano
require 'capistrano/nginx/tasks'

set :whenever_command, "bundle exec whenever"
require 'whenever/capistrano'
require './config/boot'

# airbrake in deployment mode requires money
# damn it, skip it
# require 'airbrake/capistrano'
