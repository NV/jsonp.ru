require 'jsonpwrapper'

use Rack::JSONPWrapper

app = lambda { |env|
  [200, {'Content-Type' => 'application/javascript'}, '']
}
run app
