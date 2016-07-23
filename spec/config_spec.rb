require 'spec_helper'
require './lib/cors/config'
require './spec/support/rack_app'
require 'rack'

describe "Cors::Config" do
  before :each do
    Cors::Config.send(:public, *Cors::Config.private_instance_methods)
    @configuration_file = 'spec/support/cors.yml'
    @rack_app = RackApp.new
  end

  context "when bootstrapping" do
    it 'should initialize with app state' do
      cors_config = Cors::Config.new(@rack_app)
      expect(cors_config.app).to eq @rack_app
    end

    it 'should initialize with user configuration' do
      cors_config = Cors::Config.new(@rack_app)
      expect(cors_config.user_config).to eq 'config/cors.yml'
    end

    it 'can initialize with a custom user configuration' do
      cors_config = Cors::Config.new(@rack_app, @configuration_file)
      expect(cors_config.user_config).to eq @configuration_file
    end
  end

  context "apply cors configuration" do
    it 'should load the cors configuration file' do
      config_contents = YAML.load_file(@configuration_file)
      cors_config = Cors::Config.new(@rack_app, @configuration_file)
      expect(cors_config.configure_cors).to eq config_contents
    end

    it 'should generates the cors rules from configuration' do
      cors_result_object = Marshal.load(File.binread('spec/support/success.serialized'))
      cors_config = Cors::Config.new(@rack_app, 'spec/support/cors.yml')
      config = cors_config.configure_cors
      cors = cors_config.generate_cors_rules_from_config(config)
      #File.open('spec/support/success.serialized', 'wb') {|f| f.write(Marshal.dump(cors.to_yaml))}
      expect(cors.to_yaml === cors_result_object).to eq true
    end
  end

  context "errors and exception handling" do
    it 'should notify when an unexpected error ocurrs' do
      cors_config = Cors::Config.new(@rack_app, 'spec/support/cors.yml')
      allow(cors_config).to receive(:configure_cors).and_return(nil)
      result = cors_config.call({})
      expect(result.class).to eq Cors::Config::Error
      expect(result.message.include?('Unexpected error')).to eq true
    end

    it 'should not raise an error if the configuraton file is missing' do
    end

    it 'should not raise an error if the configuration file is empty' do
    end

    it 'should notify if the configuration file does not exist' do
    end

    it 'should notifiy if the configuration file is missing' do
    end

    it 'should notifiy if the configuration file is invalid' do
    end
  end
end
