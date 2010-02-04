require 'test/unit'
require 'rack/test'
require 'fake_web'
$LOAD_PATH.unshift File.join(Dir.pwd, '..')
require 'jsonp_wrapper'

class JSONPWrapperTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    @pets = "Cat, dog, turtle, hamster, parrot\n"
    @pets_url = 'http://elv1s.ru/x/pets.txt'
    FakeWeb.register_uri :get, @pets_url, :body => @pets
    @not_found_url = 'http://example.com/404'
    FakeWeb.register_uri :get, @not_found_url, :body => 'Not found', :status => 404
  end

  def app
    JSONPWrapper.new
  end

  def test_call
    assert_respond_to app, :call
  end

  def test_open_homepage
    get '/'
    assert last_response.ok?
    assert_match /JSONP wrapper/i, last_response.body
    assert_no_match /Error/i, last_response.body
  end

  def test_fetch
    assert_respond_to app, :fetch
    assert_nil app.fetch nil
    assert_nil app.fetch ''
    assert_nil app.fetch URI.parse 'http://pwnlast.fm'
    assert_equal @pets, app.fetch(@pets_url)
    assert_nil app.fetch @not_found_url
  end

  def test_fetch_many
    assert_respond_to app, :fetch_many
    assert_nil app.fetch_many nil
    assert_nil app.fetch_many ''
    assert_nil app.fetch_many URI.parse('http://pwnlast.fm')
    assert_equal [@pets, nil], app.fetch_many([@pets_url, @not_found_url])
  end

  def test_on_pets
    pets_json = @pets.to_json
    assert_equal %Q{feed({"body":#{pets_json}});}, get("/?url=#{@pets_url}&callback=feed").body
    assert_equal %Q{feed({"body":#{pets_json}});}, get("/?url=#{@pets_url.sub('http://','')}&callback=feed").body
    assert_equal %Q{yarrr_11({"body":#{pets_json}});}, get("/?url=#{@pets_url}&callback=yarrr_11").body
  end

  def test_404
    assert_equal %Q{whoops({"body":null});}, get("/?url=#{@not_found_url}&callback=whoops").body
  end

  def test_array_with_one_url
    json = @pets.to_json
    assert_equal %Q{console.log([{"body":#{json}}]);}, get("/?urls[]=#{@pets_url}").body
  end

  def test_array_with_two_urls
    assert_equal %Q{console.log([{"body":null},{"body":#{@pets.to_json}}]);}, get('/', {'urls'=>[@not_found_url, @pets_url]}).body
  end

end