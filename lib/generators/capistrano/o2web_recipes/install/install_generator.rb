module Capistrano
  module O2webRecipes
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc "Install Nginx config files (templates)"

      def copy_files
        directory 'config'
      end
    end
  end
end
