require 'spec_helper'
require './lib/cors/config'
require 'rack'
require 'rack/mock'
require 'json'

describe "Cors Configuration Management" do
  before :each do
    Cors::Config.send(:public, *Cors::Config.private_instance_methods)
    @configuration_file = 'spec/support/cors.yml'
  end

  let(:rack_app) { lambda {|env| [200, {'Content-Type' => 'text/plain'}, env ] } } 

  context "when bootstrapping" do
    it 'should initialize with app state' do
      cors_config = Cors::Config.new(rack_app)
      expect(cors_config.app).to eq rack_app
    end

    it 'should initialize with user configuration' do
      cors_config = Cors::Config.new(rack_app)
      expect(cors_config.user_config).to eq 'config/cors.yml'
    end

    it 'can initialize with a custom user configuration' do
      cors_config = Cors::Config.new(rack_app, @configuration_file)
      expect(cors_config.user_config).to eq @configuration_file
    end
  end

  context "apply cors configuration" do
    it 'should load the cors configuration file' do
      config_contents = YAML.load_file(@configuration_file)
      cors_config = Cors::Config.new(rack_app, @configuration_file)
      expect(cors_config.configure_cors).to eq config_contents
    end

    it 'should generates the cors rules from configuration' do
      cors_result_object = Marshal.load(File.binread('spec/support/success.serialized'))
      cors_config = Cors::Config.new(rack_app, 'spec/support/cors.yml')
      config = cors_config.configure_cors
      cors = cors_config.generate_cors_rules_from_config(config)
      #File.open('spec/support/success.serialized', 'wb') {|f| f.write(Marshal.dump(cors.to_yaml))}
      expect(cors.to_yaml === cors_result_object).to eq true
    end
  end

  context "errors and exception handling" do
    it 'should notify when an unexpected error ocurrs' do
      cors_config = Cors::Config.new(rack_app, 'spec/support/cors.yml')
      allow(cors_config).to receive(:configure_cors).and_return(nil)
      expect{cors_config.call({})}.to raise_error(Cors::Config::Error, /Unexpected error/)
    end
  end
end

describe "Test Middleware With Requests" do

  let(:app) { lambda {|env| [200, {'Content-Type' => 'text/plain'}, env ] } }

  it "should return 200 if CORS configuration was applied" do
    app_with_middleware = Cors::Config.new(app, 'spec/support/cors.yml')
    env = Rack::MockRequest.env_for('/status', { :method => 'OPTIONS', 'HTTP_ORIGIN' => 'example.com',
                                                 'Access-Control-Allow-Origin' => 'example.com', 'Access-Control-Request-Method' => 'GET' })
    status, headers, body = app_with_middleware.call(env)
    expect(body["rack.cors"].hit).to eq true
  end

  it "should behave normally if CORS configuration file does not exist" do
    app_with_middleware = Cors::Config.new(app, 'spec/support/cors_some_unknown_file.yml')
    env = Rack::MockRequest.env_for('/status', { :method => 'OPTIONS', 'HTTP_ORIGIN' => 'example.com',
                                                 'Access-Control-Allow-Origin' => 'example.com', 'Access-Control-Request-Method' => 'GET' })
    status, headers, body = app_with_middleware.call(env)
    expect(body.has_key?('rack.cors')).to eq false
  end

  it "should not hit the endpoint if CORS not configured for an endpoint" do
    app_with_middleware = Cors::Config.new(app, 'spec/support/cors-empty.yml')
    env = Rack::MockRequest.env_for('/', { :method => 'GET', 'HTTP_ORIGIN' => 'example.com',
                                           'Access-Control-Allow-Origin' => 'example.com', 'Access-Control-Request-Method' => 'GET' })
    status, headers, body = app_with_middleware.call(env)
    expect(body.has_key?('rack.cors')).to eq false
  end

  it 'should notify if there was failure in parsing CORS configuration' do
    app_with_middleware = Cors::Config.new(app, 'spec/support/cors_broken.yml')
    env = Rack::MockRequest.env_for('/status', { :method => 'GET', 'HTTP_ORIGIN' => 'example.com',
                                                 'Access-Control-Allow-Origin' => 'example.com', 'Access-Control-Request-Method' => 'GET' })
    expect{app_with_middleware.call(env)}.to raise_error(Cors::Config::Error, /Unexpected error/)
  end
end
