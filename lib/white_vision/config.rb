# frozen_string_literal: true

module WhiteVision
  module Config
    mattr_accessor :sendgrid_api_key

    # Only for tests
    mattr_accessor :stub_sender

    # Basic auth for sendgrid's event webhook, optional
    mattr_accessor :webhook_basic_auth_username
    mattr_accessor :webhook_basic_auth_password

    # Where to look for html templates
    mattr_accessor(:html_templates_root)

    # Cannot set default at definition time because that's run before app initialization and `Rails.root`
    # is nil then.
    def self.read_html_templates_root
      html_templates_root || Rails.root / 'app/views/white_vision'
    end
  end
end


# Like:

# Config.recipient_klass = Subscriber
# Config.testing_recipients = ["roger@rogercampos.com"]
# Config.send_scope = -> (rel) { rel.active.not_bounced }
# Config.substitutions = {
#   '=name=' => proc { |subscriber| subscriber.name },
#   '=cancelation_url=' => proc { |subscriber| Rails.routes.cancel_url(tk: subsciber.cancel_token) }
# }