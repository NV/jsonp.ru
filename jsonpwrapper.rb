require 'net/http'
require 'json'

module Rack
  class JSONPWrapper

    def initialize(app)
      @app = app
      @file_server = Rack::File.new Dir.pwd << '/public'
    end

    def call(env)
      status, headers, response = @app.call env
      request = Rack::Request.new env
      callback = request.params.delete 'callback'
      if not callback or callback.empty?
        callback = 'grab_callback'
      end
      if request.params.include? 'url'
        url = URI.decode request.params.delete 'url'
        if url.start_with? 'http://'
          content = (JSON::generate Net::HTTP.get URI.parse url) or 'null'
          response = %Q{#{callback}({"body":#{content}});}
          headers['Content-Length'] = response.length.to_s
        end
      else
        if env['PATH_INFO'].end_with? '/'
          env['PATH_INFO'] << 'index.html'
        end
        return @file_server.call env
      end
      [status, headers, response]
    end
    
  end
end