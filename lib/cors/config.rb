require "cors/config/version"
require 'rack/cors'

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
        @config.each { |rule|
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
      return [] if File.exist?(@config)
      @configeration = YAML.load_file('config/cors.yml')
    end
  end
end

