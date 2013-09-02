require 'sprockets/redirect'

module Sprockets
  class RedirectRailtie < ::Rails::Railtie
    initializer "my_railtie.configure_rails_initialization" do |app|
      if ::Rails.configuration.assets.enabled && !::Rails.configuration.assets.compile && ::Rails.configuration.assets.digest
        app.middleware.insert_before Rack::Rewrite, Sprockets::Redirect, :digests => ::Rails.configuration.assets.digests,
                                                                      :prefix  => ::Rails.configuration.assets.prefix
      end
    end
  end
end
