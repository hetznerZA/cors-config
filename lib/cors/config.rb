require "cors/config/version"
require 'rack/cors'
require 'byebug'

module Cors
   class Config
    class CorsConfigError < StandardError; end

    def initialize(app)
      @app = app
      @user_config = 'config/cors.yml'
    end

    def call(env)
      config = configure_cors(@user_config)
      cors = Rack::Cors.new(@app, {}) do
        config['cors'].each { |rule|
          allow do
            origins rule[1]['origins']
            resource rule[1]['resource'], :headers => rule[1]['headers'].to_sym, :methods => rule[1]['headers'].to_sym
          end
        }
      end
      cors.call(env)
    rescue => error
      raise CorsConfigError.new(error.message)
    end

    private
    def configure_cors
      return [] unless File.exist?(@user_config)
      YAML.load_file(@user_config)
    end
  end
end

