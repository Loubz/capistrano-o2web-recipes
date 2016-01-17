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
