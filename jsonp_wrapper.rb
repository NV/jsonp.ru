require 'open-uri'
require 'json'

class JSONPWrapper

  def initialize
    @file_server = Rack::File.new(Dir.pwd << '/public')
  end

  def call env
    request = Rack::Request.new env
    if request.params.include? 'urls' or request.params.include? 'url'
      callback = request['callback']
      callback = 'grab_callback' if not callback or callback.empty?
      body = ''
      if urls = request['urls']
        body = fetch_many(urls).to_json
      elsif url = request['url']
        body = fetch(url).to_json
      end
      [
        200,
        {'Content-Type' => 'application/javascript'},
        %Q{#{callback}({"body":#{body}});}
      ]
    else
      env['PATH_INFO'] << 'index.html' if env['PATH_INFO'][-1, 1] == '/'
      @file_server.call env
    end
  end

  def fetch url
    raise ArgumentError if not url
    url = "http://#{url}" if url !~ %r{^https?://}
    open(url).read
  rescue
    nil
  end

  def fetch_many urls
    if urls.size > 1
      responses = []
      threads = []
      urls.each_with_index {|url, i|
        threads << Thread.new {
          responses[i] = fetch url
        }
      }
      threads.each {|t| t.join}
      responses
    elsif urls.size == 1
      urls.map {|u| fetch u}
    end
  end

end