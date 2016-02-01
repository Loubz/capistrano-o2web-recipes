module Capistrano
  module Helpers
    module Rsync
      def send_files(type, server, root = 'public')
        raise "No server given" if !server
        system "rsync --progress -rue 'ssh -p #{fetch(:port)}' #{root}/#{type} #{server.user}@#{server.hostname}:#{shared_path}/#{root}/"
      end

      def get_files(type, server, root = 'public')
        raise "No server given" if !server
        puts "Importing #{type}. Please wait..."
        system "rsync --progress -rue 'ssh -p #{fetch(:port)}' #{server.user}@#{server.hostname}:#{shared_path}/#{root}/#{type} ./#{root}/"
      end

      def upload(server, source, destination)
        File.open(source, 'w') do |f|
          f.puts ERB.new(File.read("#{source}.erb"), nil, '-').result
        end
        system "rsync --rsync-path='sudo rsync' -avzO -e 'ssh -p #{fetch(:port)}' '#{source}' #{fetch(:deployer_name)}@#{server.hostname}:#{destination}"
        FileUtils.rm_f source
      end
    end
  end
end
