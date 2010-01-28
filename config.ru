require 'jsonp_wrapper'

use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::ShowStatus

run JSONPWrapper.new
