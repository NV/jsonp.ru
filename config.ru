require 'net/http'
require 'json'

use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::ShowStatus
use Rack::Lint

run Proc.new { |env|
  file_server = Rack::File.new(Dir.pwd << '/public')
  request = Rack::Request.new env
  callback = request.params['callback']
  callback = 'grab_callback' if not callback or callback.empty?
  if request.params.include? 'url'
    response = ''
    headers = {'Content-Type' => 'application/javascript'}
    url = URI.decode request.params['url']
    if url.index('http://') == 0
      begin
        content = (Net::HTTP.get URI.parse url).to_json or 'null'
      rescue
        content = 'null'
      end
      response = %Q{#{callback}({"body":#{content}});\n}
    end
    [200, headers, response]
  else
    if env['PATH_INFO'][-1, 1] == '/'
      env['PATH_INFO'] << 'index.html'
    end
    file_server.call env
  end
}
