require 'open-uri'
require 'json'

class JSONPWrapper

  def initialize
    @file_server = Rack::File.new(Dir.pwd << '/public')
  end

  def call(env)
    request = Rack::Request.new env
    callback = request.params['callback']
    callback = 'grab_callback' if not callback or callback.empty?
    if request.params.include? 'url'
      headers = {'Content-Type' => 'application/javascript'}
      url = URI.decode request.params['url']
      url = "http://#{url}" if url !~ %r{^https?://}
      begin
        body = open(url).read.to_json or 'null'
      rescue
        body = 'null'
      end
      response = %Q{#{callback}({"body":#{body}});\n}
      [200, headers, response]
    else
      env['PATH_INFO'] << 'index.html' if env['PATH_INFO'][-1, 1] == '/'
      @file_server.call env
    end
  end

end