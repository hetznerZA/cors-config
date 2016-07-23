require "cors/config/version"
require 'rack/cors'
require 'yaml'

module Cors
  class Config
    class Error < StandardError; end
    attr_accessor :app, :user_config

    def initialize(app, user_config = 'config/cors.yml')
      @app = app
      @user_config = user_config
    end

    def call(env)
      config = configure_cors
      return @app.call(env) if config.empty?
      cors = generate_cors_rules_from_config(config)
      return @app.call(env) if cors.nil? 
      cors.call(env)
    rescue => error
      Error.new("Unexpected error #{error.message}")
    end

    private
    def generate_cors_rules_from_config(config)
      cors = Rack::Cors.new(@app, {}) do
        config['cors'].each { |rule|
          allow do
            origins rule[1]['origins']
            resource rule[1]['resource'], :headers => rule[1]['headers'].to_sym, :methods => rule[1]['headers'].to_sym
          end
        }
      end
    end

    def configure_cors
      return [] unless File.exist?(@user_config)
      YAML.load_file(@user_config)
    end
  end
end
