# Cors Config

Middleware that allows you to configure CORS via a YAML file.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cors-config'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cors-config

## Usage

In config.ru

```
use Cors::Config
```

Also the configuration is expected in config/cors.yml (for now).

```
cors:
  products:
    origins: '*'
    resource: '/products'
    headers: 'any'
    methods: 'any'
  status:
    origins: '*'
    resource: '/status'
    headers: 'any'
    methods: 'any'
```

## Contributing

Please send feedback and comments to the author at:

Dane-Garrin Balia <dane.balia@hetzner.co.za>

This gem is sponsored by Hetzner (Pty) Ltd - http://hetzner.co.za

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).