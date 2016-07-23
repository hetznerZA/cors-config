require 'rack'
require 'cors/config'

# How to include the Cors::Config Middleware
use Cors::Config

class MyApp
  def call(env)
    request = Rack::Request.new(env)
    headers = { 'Content-Type' => 'text/html' }

    case request.path
    when '/status'
      [200, headers, ["100"]]
    when '/products'
      [200, headers, ["Hello, developer! Your products are: MacBook"]]
    else
      [404, headers, ["Uh oh, path not found!"]]
    end
  end
end

run MyApp.new
