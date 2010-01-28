require 'test/unit'
require 'rack/test'
$LOAD_PATH.unshift File.join(Dir.pwd, '..')
require 'jsonp_wrapper'

class JSONPWrapperTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    JSONPWrapper.new
  end

  def test_open_homepage
    get '/'
    assert last_response.ok?
    assert_match /JSONP wrapper/i, last_response.body
    assert_no_match /Error/i, last_response.body
  end

  def test_on_pets
    pets_url = 'http://elv1s.ru/x/pets.txt' # TODO: test it on localhost
    pets_json = open(pets_url).read.to_json
    assert_equal %Q{feed({"body":#{pets_json}});\n}, get("/?url=#{pets_url}&callback=feed").body
    assert_equal %Q{feed({"body":#{pets_json}});\n}, get("/?url=#{pets_url.sub('http://','')}&callback=feed").body
    assert_equal %Q{yarrr_11({"body":#{pets_json}});\n}, get("/?url=#{pets_url}&callback=yarrr_11").body
    assert_equal %Q{whoops({"body":null});\n}, get("/?url=/&callback=whoops").body
  end

end