# -*- encoding : utf-8 -*-
set :application, "agsexplorer"
set :server_name, "www.agsexplorer.com agsexplorer.com *.agsexplorer.com"
set :domain,      "180.153.142.123" #ey180
set :repository,  "git@github.com:AlexChien/agsexplorer.git"
set :use_sudo,    false
set :deploy_to,   "/usr/local/webservice/htdocs/#{application}"
set :scm,         "git"
set :user,        "mongrel"
set :runner,      "mongrel"
set :sudo_user,   "mongrel"
set :rake,        'rake'  #"/opt/ruby-enterprise/bin/rake"
set :keep_releases, 5
set :rvm_ruby_string, '1.9.3@agsexplorer'
set :passenger_ruby, '/home/mongrel/.rvm/wrappers/ruby-1.9.3-p392/ruby'
set :rvm_type, :user
set :nginx_conf_path, "/opt/nginx/conf/vh_180"
set :asset_env, "RAILS_GROUPS=assets"

# Whatever you set here will be taken set as the default RAILS_ENV value
# on the server. Your app and your hourly/daily/weekly/monthly scripts
# will run with RAILS_ENV set to this value.
set :rails_env, "production"
set :bundle_cmd, "bundle" #"/opt/ruby-enterprise/bin/bundle"
# without darwin, since we are using rb-fsevent gem on mac
set :bundle_without, [:darwin, :development, :test]
default_run_options[:pty] = true
set :default_environment, {
  'JAVA_HOME' => '/usr/local/java/jdk1.5/jdk1.5.0_22'
}

# NOTE: for some reason Capistrano requires you to have both the public and
# the private key in the same folder, the public key should have the
# extension ".pub".
ssh_options[:keys] = ["#{ENV['HOME']}/.ssh/id_rsa"]

set :scm, :git
set :scm_verbose, true
set :branch, "master"

set :deploy_via, :remote_cache

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do

  desc "Generate database.yml and Create asset packages for production, minify and compress js and css files"
  # after "deploy:update_code", :roles => [:web] do
  after "deploy:finalize_update", :roles => [:web] do
    # database_yml task cannot be put in after "deploy:update_code" trigger
    # it will conflict with asset:precompile
    database_yml
    # asset_packager
    run "ln -s #{shared_path}/bundle #{current_release}/vendor/bundle"
    migrate
  end

  # [Deprecation Warning] This API has changed, please hook `deploy:create_symlink` instead of `deploy:symlink`.
  # add soft link script for deploy
  desc "Symlink the upload directories"
  after "deploy:create_symlink", :roles => [:web] do
    # run "ln -s #{shared_path}/ckeditor_assets #{current_release}/public/ckeditor_assets"
    # run "ln -s #{shared_path}/page_cache #{current_release}/public/cache"
  end

  desc "Migrate db"
  task :migrate, :roles => [:web] do
    run "cd #{latest_release} && #{bundle_cmd} exec #{rake} db:migrate RAILS_ENV=#{rails_env}"
  end

  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end


  desc "Generate Production database.yml"
  task :database_yml, :roles => [:web] do
    db_config = "#{shared_path}/config/database.yml.production"
    run "cp #{db_config} #{release_path}/config/database.yml"
  end

  namespace :assets do
    desc <<-DESC
    Run the asset precompilation rake task. You can specify the full path \
    to the rake executable by setting the rake variable. You can also \
    specify additional environment variables to pass to rake via the \
    asset_env variable. The defaults are:

    set :rake,      "rake"
    set :rails_env, "production"
    set :asset_env, "RAILS_GROUPS=assets"
    DESC
    # task :precompile, :roles => :web, :except => { :no_release => true } do
    #   run "cd #{latest_release} && #{bundle_cmd} exec #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile"
    # end
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision) rescue nil

      if from.nil? || capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{bundle_cmd} exec #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end


  def try_killing_resque_workers
    run "pkill -3 -f agsexplorer-resque"
  rescue
    nil
  end

  desc "Restart God gracefully"
  task :restart_god, :roles => :app do
    god_config_path = File.join(current_release, 'config', 'app.god')
    begin
      # run "god status"
      run "cd #{current_release}; bundle exec god load #{god_config_path}"
      run "cd #{current_release}; bundle exec god start agsexplorer-resque"

      # Kill resque processes and have god restart them with the newly loaded config.
      try_killing_resque_workers
    rescue => ex
      # god is dead, workers should be as well, but who knows.
      try_killing_resque_workers

      # Start god.
      run "cd #{current_release}; bundle exec god -c #{god_config_path}"
    end
  end

end

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end

after "deploy", "rvm:trust_rvmrc"
# after :"deploy:restart", :"deploy:restart_god"
