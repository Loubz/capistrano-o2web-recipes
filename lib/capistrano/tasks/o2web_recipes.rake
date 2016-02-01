require 'erb'

namespace :load do
  task :defaults do
    set :files_public_dirs, ['system']
    set :files_private_dirs, []

    set :nginx_max_body_size, '10m'
    set :nginx_public_dirs, ['system', 'images']
    set :nginx_public_files, ['404.html', '422.html', '500.html', 'favicon.ico']
    set :nginx_redirects, {}
  end
end

Rake::Task["deploy:compile_assets"].clear

namespace :deploy do
  desc 'Compile assets'
  task :compile_assets => [:set_rails_env] do
    # invoke 'deploy:assets:precompile'
    invoke 'deploy:assets:precompile_local'
    invoke 'deploy:assets:backup_manifest'
  end

  namespace :assets do
    desc "Precompile assets locally and then rsync to web servers"
    task :precompile_local do
      # compile assets locally
      run_locally do
        DB = YAML.load_file('config/database.yml')['development']
        db_connection = "#{DB['adapter']}://#{DB['username']}:#{DB['password']}@#{DB['host']}/#{DB['database']}"
        execute "RAILS_ENV=#{fetch(:stage)} DATABASE_URL=#{db_connection} bundle exec rake assets:precompile"
      end

      # rsync to each server
      local_dir = "./public/assets/"
      on roles( fetch(:assets_roles, [:web]) ) do
        # this needs to be done outside run_locally in order for host to exist
        remote_dir = "#{host.user}@#{host.hostname}:#{release_path}/public/assets/"

        run_locally { execute "rsync -av --delete #{local_dir} #{remote_dir}" }
      end

      # clean up
      run_locally { execute "rm -rf #{local_dir}" }
    end
  end

  after :deploy, :touch_cron_log do
    on roles :app do
      within shared_path do
        execute :touch, 'log/cron.log'
      end
    end
  end
end

namespace :git do
  desc 'Update new git repo url'
  task :update_repo_url do
    on roles :app do
      within repo_path do
        execute :git, 'remote', 'set-url', 'origin', fetch(:repo_url)
      end
    end
  end
end

namespace :tmp_cache do
  desc 'Clear file system tmp cache'
  task :clear do
    on roles :app do
      within current_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'tmp:cache:clear'
        end
      end
    end
  end
end

namespace :files do
  def send_files(type, server, root = 'public')
    raise "No server given" if !server
    system "rsync --progress -rue 'ssh -p #{fetch(:port)}' #{root}/#{type} #{server.user}@#{server.hostname}:#{shared_path}/#{root}/"
  end

  def get_files(type, server, root = 'public')
    raise "No server given" if !server
    puts "Importing #{type}. Please wait..."
    system "rsync --progress -rue 'ssh -p #{fetch(:port)}' #{server.user}@#{server.hostname}:#{shared_path}/#{root}/#{type} ./#{root}/"
  end

  desc 'Import public files'
  task :server_to_local do
    on roles :app do |host|
      fetch(:files_public_dirs).each do |type|
        get_files type, host
      end
    end
  end

  desc 'Export public files'
  task :local_to_server do
    on roles :app do |host|
      fetch(:files_public_dirs).each do |type|
        send_files type, host
      end
    end
  end

  namespace :private do
    desc 'Import private files'
    task :server_to_local do
      on roles :app do |host|
        fetch(:files_private_dirs).each do |type|
          get_files type, host, 'private'
        end
      end
    end

    desc 'Export private files'
    task :local_to_server do
      on roles :app do |host|
        fetch(:files_private_dirs).each do |type|
          send_files type, host, 'private'
        end
      end
    end
  end
end

namespace :db do
  desc "Sync local DB with server DB"
  task :server_to_local do
    on roles(:app) do |role|
      within current_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'db:data:dump'
        end
        run_locally do
          execute :rsync, "-avzO -e 'ssh -p #{fetch(:port)}' --exclude='.DS_Store' #{role.user}@#{role.hostname}:#{current_path}/db/data.yml db/data.yml"
        end
      end
    end
  end

  desc "Sync server DB with local DB"
  task :local_to_server do
    on roles(:app) do |role|
      run_locally do
        execute :rsync, "-avzO -e 'ssh -p #{fetch(:port)}' --exclude='.DS_Store' db/data.yml #{role.user}@#{role.hostname}:#{current_path}/db/data.yml"
      end
      within current_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'db:data:load'
        end
      end
    end
  end
end

namespace :nginx do
  def upload(server, source, destination)
    File.open(source, 'w') do |f|
      f.puts ERB.new(File.read("#{source}.erb"), nil, '-').result
    end
    system "rsync --rsync-path='sudo rsync' -avzO -e 'ssh -p #{fetch(:port)}' '#{source}' #{fetch(:deployer_name)}@#{server.hostname}:#{destination}"
    FileUtils.rm_f source
  end

  desc 'Export nginx configuration files'
  task :local_to_server do
    on roles :app do |host|
      upload host, 'config/nginx.conf', '/etc/nginx/nginx.conf'
      upload host, 'config/nginx.app.conf', '/etc/nginx/sites-available/default'
    end
  end
end
