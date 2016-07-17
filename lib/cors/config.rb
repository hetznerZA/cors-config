require "cors/config/version"
require 'rack/cors'
require 'rack/builder'

module Cors
  class Config
    class CorsConfigError < StandardError; end

    def initialize(app)
      @config = 'config/cors.yml'
      @app = app
      configure_cors
    end

    def call(env)
      return @app.call(env) if @config.empty?
      cors = Rack::Cors.new(@app, {}) do
        @configuration.each { |config|
          allow do
            origins config[1]['origins']
            resource config[1]['resource'], :headers => config[1]['headers'].to_sym, :methods => config[1]['headers'].to_sym
          end
        }
      end
      cors.call(env)
    rescue => error
      raise CorsConfigError.new(error.message)
    end

    private
    def configure_cors
      return [] if File.exist?(@config)
      @configeration = YAML.load_file('config/cors.yml')
    end
  end
end
