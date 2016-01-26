require 'rack'
require 'rack/request'
require 'rack/mime'
require 'active_support/core_ext/class/attribute'
require 'yaml'

module Sprockets
  # A Rack middleware for Rails >= 3.1.0 with asset pipeline and asset digest
  # enabled. This middleware is used to redirect any request to static asset
  # without a digest to the version with digest in its filename by reading the
  # manifest.yml file generated after you run rake assets:precompile
  #
  # For example, if a browser is requesting this URL:
  #
  #   http://example.org/assets/application.js
  #
  # They will get redirected to:
  #
  #   http://example.org/assets/application-faa42cf2fd5db7e7290baa07109bc82b.js
  #
  # This middleware is designed to run on your staging or production environment,
  # where you already precompile all your assets, turn on your asset digest, and
  # turn of asset compilation. This is useful if you're having a static page or
  # E-Mail which refers to static assets in the asset pipeline, which might be
  # impossible and impractical for you to use an URL with a digest in it.
  class Redirect
    # Set this to false to disable middleware's redirection
    class_attribute :enabled
    self.enabled = true

    # Set the status code use for redirection
    class_attribute :redirect_status
    self.redirect_status = 302

    def initialize(app, sprockets_environment, options = {})
      @app = app
      @prefix = options[:prefix] || "/assets"
      @asset_host = options[:asset_host]
      @environment = sprockets_environment
    end

    def call(env)
      @request = Rack::Request.new(env)

      if should_redirect?
        redirect_to_digest_version(env)
      else
        @app.call(env)
      end
    end

    private

    def should_redirect?
      self.class.enabled && asset_path_matched?
    end

    # This will returns true if a requested path is matched in the digests hash
    def asset_path_matched?
      @request.path.start_with?(@prefix) && asset_exists?
    end

    def asset_exists?
      @environment[logical_path]
    end

    def logical_path
      @request.path.sub(/^#{@prefix}\//, "")
    end

    def digest_path
      if @environment[logical_path].respond_to?(:digest_path)
        @environment[logical_path].digest_path
      else
        @environment[logical_path]
      end
    end

    # Sends a redirect header back to browser
    def redirect_to_digest_version(env)
      url = URI(computed_asset_host || @request.url)
      url.path = "#{@prefix}/#{digest_path}"

      headers = { 'Location'      => url.to_s,
                  'Content-Type'  => Rack::Mime.mime_type(::File.extname(digest_path)),
                  'Pragma'        => 'no-cache',
                  'Cache-Control' => 'no-cache; max-age=0' }

      [self.class.redirect_status, headers, [redirect_message(url.to_s)]]
    end

    def computed_asset_host
      if @asset_host.respond_to?(:call)
        host = @asset_host.call(@request)
      else
        host = @asset_host
      end

      if host.nil? || host =~ %r(^https?://)
        host
      else
        "#{@request.scheme}://#{host}"
      end
    end

    # Create a default redirect message
    def redirect_message(location)
      %Q(Redirecting to <a href="#{location}">#{location}</a>)
    end
  end
end
