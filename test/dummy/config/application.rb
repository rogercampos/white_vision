require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "white_vision"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.to_prepare do
      puts "Required now."
      require_dependency 'test_1'
      require_dependency 'test_2'
    end
  end
end

