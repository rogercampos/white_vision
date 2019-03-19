# frozen_string_literal: true

module WhiteVision
  module Config
    mattr_accessor :sendgrid_api_key
    mattr_accessor :stub_sender
  end
end


# Like:

Config.recipient_klass = Subscriber
Config.testing_recipients = ["roger@rogercampos.com"]
Config.send_scope = -> (rel) { rel.active.not_bounced }
Config.substitutions = {
  '=name=' => proc { |subscriber| subscriber.name },
  '=cancelation_url=' => proc { |subscriber| Rails.routes.cancel_url(tk: subsciber.cancel_token) }
}