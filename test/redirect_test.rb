require 'sprockets/redirect'
require 'test/unit'
require 'rack/test'
require 'active_support'
require 'mocha/setup'

puts ">> Testing against Rails #{ActiveSupport::VERSION::STRING}"

class TestRedirect < Test::Unit::TestCase
  include Rack::Test::Methods

  def default_app
    lambda { |env|
      headers = {'Content-Type' => "text/html"}
      [200, headers, ["OK"]]
    }
  end

  def app
    @app ||= build_app
  end
  attr_writer :app

  def build_app(options = {})
    @environment = {'application.js' => stub(digest_path: 'application-1a2b3c4d5e.js')}
    self.app = Sprockets::Redirect.new(default_app, @environment, options)
  end

  def test_redirect_matched_assets
    get "http://example.org/assets/application.js"
    assert_equal "http://example.org/assets/application-1a2b3c4d5e.js",
      last_response.headers['Location']
  end

  def test_redirect_set_content_type
    get "http://example.org/assets/application.js"
    assert_equal "application/javascript", last_response.headers['Content-Type']
  end

  def test_pass_unmached_assets
    get "http://example.org/assets/unmatched.js"
    assert last_response.ok?
  end

  def test_setting_prefix
    build_app(:prefix => "/hidden_assets")
    get "http://example.org/assets/application.js"
    assert last_response.ok?

    get "http://example.org/hidden_assets/application.js"
    assert last_response.redirect?
  end
  
  def test_setting_asset_host
    build_app(:asset_host => "http://test.cloudfront.com")

    get "http://example.org/assets/application.js"
    assert_equal "http://test.cloudfront.com/assets/application-1a2b3c4d5e.js",
      last_response.headers['Location']
  end

  def test_set_enabled_to_false
    old_enabled = Sprockets::Redirect.enabled
    Sprockets::Redirect.enabled = false

    get "http://example.org/assets/application.js"
    assert last_response.ok?
  ensure
    Sprockets::Redirect.enabled = old_enabled
  end

  def test_setting_redirect_status
    old_redirect_status = Sprockets::Redirect.redirect_status
    Sprockets::Redirect.redirect_status = 301

    get "http://example.org/assets/application.js"
    assert_equal 301, last_response.status
  ensure
    Sprockets::Redirect.enabled = old_redirect_status
  end
end
