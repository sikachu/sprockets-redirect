require 'sprockets/redirect'

module Sprockets
  class RedirectRailtie < ::Rails::Railtie
    initializer "insert_sprockets_redirect_middleware" do |app|
      if !::Rails.configuration.assets.compile && ::Rails.configuration.assets.digest
        app.middleware.insert 0,
          Sprockets::Redirect,
          ::Rails.application.assets ||
            Sprockets::Railtie.build_manifest(::Rails.application).assets,
          :prefix => ::Rails.configuration.assets.prefix,
          :asset_host => ::Rails.configuration.action_controller.asset_host
      end
    end
  end
end
