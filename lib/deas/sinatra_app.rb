require 'sinatra/base'

module Deas

  module SinatraApp

    def self.new(server_config)
      server_config.init_proc.call
      server_config.routes.each(&:constantize!)

      Class.new(Sinatra::Base).tap do |app|

        # built-in settings
        app.set :environment, server_config.env
        app.set :root,        server_config.root

        app.set :app_file,      server_config.app_file
        app.set :public_folder, server_config.public_folder
        app.set :views,         server_config.views_folder

        app.set :dump_errors,     server_config.dump_errors
        app.set :logging,         false
        app.set :method_override, server_config.method_override
        app.set :sessions,        server_config.sessions
        app.set :show_exceptions, server_config.show_exceptions
        app.set :static,          server_config.static_files

        # custom settings
        app.set :logger,        server_config.logger
        app.set :runner_logger, server_config.runner_logger

        # routes
        server_config.routes.each do |route|
          # defines Sinatra routes like:
          #   before('/'){ ... }
          #   get('/'){ ... }
          #   after('/'){ ... }
          app.before(route.path) do
            @runner = route.runner(self).setup
          end
          app.send(route.method, route.path) do
            @runner.run
          end
          app.after(route.path) do
            @runner.teardown
          end
        end

      end
    end

  end

end
