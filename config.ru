require 'jsonpwrapper'

use Rack::JSONPWrapper
use Rack::ContentLength

app = lambda { |env|
  [200, {'Content-Type' => 'application/javascript'}, '']
}
run app
