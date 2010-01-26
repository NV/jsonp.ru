require 'open-uri'
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
    headers = {'Content-Type' => 'application/javascript'}
    url = URI.decode request.params['url']
    url = "http://#{url}" if url !~ %r{^https?://}
    begin
      content = open(url).read.to_json or 'null'
    rescue
      content = 'null'
    end
    response = %Q{#{callback}({"body":#{content}});\n}
    [200, headers, response]
  else
    if env['PATH_INFO'][-1, 1] == '/'
      env['PATH_INFO'] << 'index.html'
    end
    file_server.call env
  end
}
