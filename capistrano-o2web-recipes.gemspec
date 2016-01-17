# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/o2web_recipes/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano-o2web-recipes"
  gem.version       = Capistrano::O2webRecipes::VERSION
  gem.authors       = ["Patrice Lebel"]
  gem.email         = ["patrice@lebel.com"]
  gem.description   = "Common Capistrano Recipes used by O2Web."
  gem.summary       = "Common Capistrano Recipes used by O2Web."
  gem.homepage      = "https://github.com/o2web/capistrano-o2web-recipes"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "capistrano", ">= 3.1"
  gem.add_dependency "capistrano3-nginx", "~> 2.0"
  gem.add_dependency "yaml_db"
  gem.add_development_dependency "rake"
end
