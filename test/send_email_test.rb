require 'test_helper'

class WhiteVision::Test < ActiveSupport::TestCase
  include TestHelpers

  test 'sends the given email' do
    WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                   from: 'Cuca <cuca@msn.com>',
                                   subject: 'Hellou',
                                   message: '<h1>BOO</h1>',
                                   format: :html,
                                   track_success: false


    email_sent = parse_sendgrid_email(peleka_sent_emails.first)

    assert email_sent
    assert_equal 'Hellou', email_sent.subject
    assert_equal 'cuca@msn.com', email_sent.from_email
    assert_equal 'Cuca', email_sent.from_name
    assert_equal 'jon.doe@gmail.com', email_sent.to_email
    assert_equal 'Jon', email_sent.to_name
    assert_equal '<h1>BOO</h1>', email_sent.body
  end

  test 'persists the email' do
    sent_email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                                from: 'Cuca <cuca@msn.com>',
                                                subject: 'Hellou',
                                                format: :html,
                                                message: '<h1>BOO</h1>',
                                                track_success: true,
                                                success_rule: 'by_click',
                                                success_url_regexp: 'facebook.com',
                                                template_id: "Foo",
                                                extra_data: { subscriber_id: 12 }


    assert_equal 1, WhiteVision::EmailRecord.count

    assert_equal true, sent_email.track_success
    assert_equal 'by_click', sent_email.success_rule
    assert_equal 'facebook.com', sent_email.success_url_regexp
    assert_equal 'Jon <jon.doe@gmail.com>', sent_email.recipient
    assert_equal 'Hellou', sent_email.subject
    assert_equal 'Foo', sent_email.template_id
    assert_equal({ "subscriber_id" => 12 }, sent_email.extra_data)
  end

  test 'fails when missing required data' do
    required_data = {
      recipient: 'Jon <jon.doe@gmail.com>',
      from: 'Cuca <cuca@msn.com>',
      subject: 'Hellou',
      message: '<h1>BOO</h1>',
      format: :html,
      track_success: false
    }

    required_data.keys.each do |required_attr|
      error = assert_raise(WhiteVision::Sender::InvalidInput) do
        WhiteVision::Sender.send_email required_data.except(required_attr)
      end

      assert_equal "{:#{required_attr}=>[\"is missing\"]}", error.message
    end
  end

  test 'fails if track success but no rule' do
    assert_raise(WhiteVision::Sender::InvalidInput) do
      WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                     from: 'Cuca <cuca@msn.com>',
                                     subject: 'Hellou',
                                     message: '<h1>BOO</h1>',
                                     format: :html,
                                     track_success: true
    end
  end
end
