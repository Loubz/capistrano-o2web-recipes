# Capistrano::O2webRecipes

Common Capistrano Recipes used by O2Web.

Works *only* with Capistrano 3+.

### Installation

Add this to `Gemfile`:

    group :development do
      gem 'capistrano', '~> 3.1'
      gem 'capistrano-rails', '~> 1.1'
      gem 'capistrano-o2web-recipes', '~> 0.0.1'
    end

And then:

    $ bundle install

### Setup and usage

Add this line to `Capfile`, after `require 'capistrano/rails/assets'`

    require 'capistrano/o2web_recipes'
    
To install Nginx config files, run:

    $ rails g capistrano:o2web_recipes:install
    
Available tasks:

```bash
cap [stage] git:update_repo_url           # Update new git repo url
cap [stage] tmp_cache:clear               # Clear file system tmp cache
cap [stage] files:server_to_local         # Import public files
cap [stage] files:local_to_server         # Export public files
cap [stage] files:private:server_to_local # Import private file
cap [stage] files:private:local_to_server # Export private files
cap [stage] db:server_to_local            # Sync local DB with server DB
cap [stage] db:local_to_server            # Sync server DB with local DB
cap [stage] nginx:local_to_server         # Export nginx configuration files
```

Also, tasks from 'capistrano3-nginx' are available.

Configurations can be customized in your deploy file with:

```ruby
set :server, 'example.com'
set :admin_name, 'admin'
set :deployer_name, 'deployer'
set :files_public_dirs, fetch(:files_public_dirs, []).push(*%W[
  system
])
set :files_private_dirs, fetch(:files_private_dirs, []).push(*%W[
])
set :nginx_workers, 1
set :nginx_assets_dirs, fetch(:nginx_assets_dirs, []).push(*%W[
  assets
  system
])
set :nginx_max_body_size, '10m'
```

### TODO

1. Use stages (staging/production) to scope Nginx config file to allow multiple stages on the same server.
1. Lose the dependency to capistrano3-nginx gem.
1. Log rotate
1. Monit
