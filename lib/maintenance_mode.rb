# Helper module to put site in maintenance mode.
# Configure in initializer, example:
#
# MaintenanceMode.configure do |config|
#   config.enabled = ENV['MAINTENANCE_MODE'].present?
#   config.retry_after = 3600
# end
#
# For the above example you can use Template deploy to
# update environment to have:
# MAINTENANCE_MODE: any-old-value-as-var-presence-is-enough
#
module MaintenanceMode
  class Configuration
    attr_accessor :enabled, :retry_after

    def initialize
      @enabled = false
      @retry_after = 3600
    end

    def enabled?
      enabled
    end
  end

  class << self
    attr_writer :configuration
    delegate :retry_after, :enabled?, to: :configuration

    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

    def configure
      yield(configuration) if block_given?
      configuration
    end

    def routes
      return unless enabled?
      Rails.application.routes.draw do
        root to: 'maintenance#index', via: :all
        match '*path', to: 'maintenance#index', via: :all
      end
    end
  end
end
