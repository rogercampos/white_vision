require 'test_helper'

class WhiteVision::SendEmailTemplateTest < ActiveSupport::TestCase
  include TestHelpers

  class MyEmail < WhiteVision::HtmlEmail
    def initialize(name = "Jon")
      @name = name
    end

    def subject
      "Hello"
    end

    def from
      'Cuca <cuca@msn.com>'
    end

    def track_success?
      false
    end

    def html_template
      'my_email.html'
    end

    def replacements
      { "=name=" => @name }
    end
  end

  test 'sends the given email' do
    email = MyEmail.new "Robert"
    WhiteVision::Sender.send_email_template email, recipient: 'Jon <jon.doe@gmail.com>'

    email_sent = parse_sendgrid_email(peleka_sent_emails.first)

    assert email_sent
    assert_equal 'Hello', email_sent.subject
    assert_equal 'cuca@msn.com', email_sent.from_email
    assert_equal 'Cuca', email_sent.from_name
    assert_equal 'jon.doe@gmail.com', email_sent.to_email
    assert_equal 'Jon', email_sent.to_name
    assert_equal '<h1>Hello Robert!</h1>', email_sent.body
  end
end
