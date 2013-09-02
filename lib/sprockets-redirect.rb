require 'sprockets/redirect'

module Sprockets
  class RedirectRailtie < ::Rails::Railtie
    initializer "my_railtie.configure_rails_initialization" do |app|
    end
  end
end
