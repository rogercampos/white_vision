# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
ENV["BACKTRACE"] = "true"


require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require "rails/test_help"


# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end



module CommonHelpers
  def initialize(*)
    @stub_saved_config = {}
    super
  end

  def use_config(data)
    data.each do |config, value|
      raise "#{config} Not known?" unless  WhiteVision::Config.respond_to?(config)

      @stub_saved_config[config] = WhiteVision::Config.send(config)
      WhiteVision::Config.send("#{config}=", value)
    end
  end

  def teardown
    super
    return unless @stub_saved_config

    @stub_saved_config.each do |config, value|
      WhiteVision::Config.send("#{config}=", value)
    end
  end
end

module PelekaHelpers
  module PelekaMock
    class Sender
      attr_reader :sent_emails

      def initialize
        @sent_emails = []
      end

      def call(json)
        @sent_emails.push(json)
      end
    end
  end

  class SendgridEmailJson
    def initialize(json)
      @json = json
    end

    def from_name
      @json['from']['name']
    end

    def from_email
      @json['from']['email']
    end

    def to_name
      @json['personalizations'].first['to'].first['name']
    end

    def to_email
      @json['personalizations'].first['to'].first['email']
    end

    def subject
      @json['subject']
    end

    def body
      @json['content'].first['value']
    end

    def custom_args
      @json['custom_args']
    end

    alias recipient to_email
  end

  def setup
    ::WhiteVision::Config.stub_sender = @peleka_mock_sender = PelekaMock::Sender.new
    ::WhiteVision::Config.sendgrid_api_key = 'test'
    peleka_sent_emails.clear

    super
  end

  def peleka_sent_emails
    @peleka_mock_sender.sent_emails
  end

  def parse_sendgrid_email(json)
    SendgridEmailJson.new(json)
  end

  def peleka_simulate(event_name, id, extra = {})
    common = { white_vision_id: id, timestamp: Time.current.to_i, ip: '1.1.1.1' }.merge(extra)
    WhiteVision::EventProcessor.process([common.merge(event: event_name.to_s).stringify_keys])
  end
end


module TestHelpers
  include CommonHelpers
  include PelekaHelpers
end
