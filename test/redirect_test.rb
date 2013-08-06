require 'sprockets/redirect'
require 'test/unit'
require 'rack/test'
require 'active_support'

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
    options = {:digests => {'application.js' => 'application-1a2b3c4d5e.js'}}.merge(options)
    self.app = Sprockets::Redirect.new(default_app, options)
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

  def test_setting_digests
    build_app(:digests => {'foo.css' => 'foo-1a2b3c4d5e.css'})
    get "http://example.org/assets/application.js"
    assert last_response.ok?

    get "http://example.org/assets/foo.css"
    assert_equal "http://example.org/assets/foo-1a2b3c4d5e.css",
      last_response.headers['Location']
  end

  def test_setting_prefix
    build_app(:prefix => "/hidden_assets")
    get "http://example.org/assets/application.js"
    assert last_response.ok?

    get "http://example.org/hidden_assets/application.js"
    assert last_response.redirect?
  end

  def test_setting_manifest_on_class_take_precedence
    old_manifest = Sprockets::Redirect.manifest
    fixture_file = File.expand_path(File.dirname(__FILE__) + '/fixtures/manifest.yml')
    Sprockets::Redirect.manifest = fixture_file.to_s

    get "http://example.org/assets/application.js"
    assert_equal "http://example.org/assets/application-l33t.js",
      last_response.headers['Location']
  ensure
    Sprockets::Redirect.manifest = old_manifest
  end

  def test_setting_manifest_on_initialize_take_precedence
    fixture_file = File.expand_path(File.dirname(__FILE__) + '/fixtures/manifest.yml')
    build_app(:manifest => fixture_file)

    get "http://example.org/assets/application.js"
    assert_equal "http://example.org/assets/application-l33t.js",
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
