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

    # Set a path to manifest file, which will be used for lookup
    class_attribute :manifest
    self.manifest = nil

    # Set this to false to disable middleware's redirection
    class_attribute :enabled
    self.enabled = true

    # Set the status code use for redirection
    class_attribute :redirect_status
    self.redirect_status = 302

    def initialize(app, options = {})
      @app = app
      @digests = options[:digests] || nil
      @prefix = options[:prefix] || "/assets"
      if manifest = options[:manifest] || self.class.manifest
        @digests = YAML.load_file manifest
      end
    end

    def call(env)
      if self.class.enabled && @digests.present? && asset_match?(env)
        redirect_to_digest_version(env)
      else
        @app.call(env)
      end
    end

    protected

    # This will returns true if a requested path is matched in the digests hash
    def asset_match?(env)
      @request = Rack::Request.new(env)
      @request.path.match(/^#{@prefix}/) && @digests[@request.path.sub(/^#{@prefix}\//, "")]
    end

    # Sends a redirect header back to browser
    def redirect_to_digest_version(env)
      url = URI(@request.url)
      filename = @digests[@request.path.sub("#{@prefix}/", "")].digest_path
      url.path = "#{@prefix}/#{filename}"
      headers = { 'Location'      => url.to_s,
                  'Content-Type'  => Rack::Mime.mime_type(::File.extname(filename)),
                  'Pragma'        => 'no-cache',
                  'Cache-Control' => 'no-cache; max-age=0' }
      [self.class.redirect_status, headers, [redirect_message(url.to_s)]]
    end

    # Create a default redirect message
    def redirect_message(location)
      %Q(Redirecting to <a href="#{location}">#{location}</a>)
    end
  end
end
