# frozen_string_literal: true

require 'test_helper'

module WhiteVision
  class EventProcessorTest < ActiveSupport::TestCase
    include PelekaHelpers

    test 'tracks processing' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"

      time = Time.current

      travel_to(time) do
        peleka_simulate(:processed, email.id)
        email.reload

        assert email.processed?
        assert_equal time.to_i, email.processed_at.to_i
      end
    end

    test 'tracks delivered' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"

      time = Time.current

      travel_to(time) do
        peleka_simulate(:delivered, email.id)
        email.reload

        assert email.delivered?
        assert_equal time.to_i, email.delivered_at.to_i
      end
    end

    test 'track first open at' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"

      time = Time.current

      travel_to(time) do
        peleka_simulate(:open, email.id)
        email.reload

        assert_equal time.to_i, email.last_open_at.to_i
      end
    end

    test 'tracks success by open' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: true,
                                             success_rule: 'by_open',
                                             template_id: "test"

      time = Time.current

      travel_to(time) do
        peleka_simulate(:open, email.id)
        email.reload

        assert email.success?
      end
    end

    test 'tracks clicks' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"


      time = Time.current

      travel_to(time) do
        peleka_simulate(:click, email.id)
        email.reload

        assert_equal time.to_i, email.last_click_at.to_i
      end
    end

    test 'tracks success by click on any link' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: true,
                                             success_rule: 'by_click',
                                             template_id: "test"


      time = Time.current

      travel_to(time) do
        peleka_simulate(:click, email.id)
        email.reload

        assert email.success?
      end
    end

    test 'tracks success by click on specific urls' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: true,
                                             success_rule: 'by_click',
                                             success_url_regexp: "(facebook.com|google.com)",
                                             template_id: "test"


      time = Time.current

      travel_to(time) do
        peleka_simulate(:click, email.id)
        email.reload
        refute email.success?

        peleka_simulate(:click, email.id, url: 'https://facebook.com/something')
        email.reload

        assert email.success?
      end
    end

    test 'track drops' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"


      time = Time.current

      travel_to(time) do
        peleka_simulate(:dropped, email.id, reason: 'because sudo drop')
        email.reload

        assert email.dropped?
        assert_equal 'because sudo drop', email.drop_reason
      end
    end

    test 'tracks bounces' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"


      time = Time.current

      travel_to(time) do
        peleka_simulate(:bounce, email.id, type: 'bounce')
        email.reload

        assert email.bounced?
      end
    end

    test 'tracks blocks' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"


      time = Time.current

      travel_to(time) do
        peleka_simulate(:bounce, email.id, type: 'blocked')
        email.reload

        assert email.blocked?
      end
    end

    test 'tracks total opens' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"


      peleka_simulate(:open, email.id)
      peleka_simulate(:open, email.id)
      email.reload

      assert_equal 2, email.total_opens
    end

    test 'tracks total clicks' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"


      peleka_simulate(:click, email.id)
      peleka_simulate(:click, email.id)
      email.reload

      assert_equal 2, email.total_clicks
    end

    test 'tracks first_open_at even with unordered callbacks' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"


      time = Time.current

      travel_to(time) do
        peleka_simulate(:open, email.id)
        email.reload

        assert_equal time.to_i, email.first_open_at.to_i
      end

      back_in_time = time - 3.hours

      travel_to(back_in_time) do
        peleka_simulate(:open, email.id)
        email.reload

        assert_equal back_in_time.to_i, email.first_open_at.to_i
      end
    end

    test 'tracks first_click_at even with unordered callbacks' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"


      time = Time.current

      travel_to(time) do
        peleka_simulate(:click, email.id)
        email.reload

        assert_equal time.to_i, email.first_click_at.to_i
      end

      back_in_time = time - 3.hours

      travel_to(back_in_time) do
        peleka_simulate(:click, email.id)
        email.reload

        assert_equal back_in_time.to_i, email.first_click_at.to_i
      end
    end

    test 'tracks ip on opening' do
      email = WhiteVision::Sender.send_email recipient: 'Jon <jon.doe@gmail.com>',
                                             from: 'Cuca <cuca@msn.com>',
                                             subject: 'Hellou',
                                             html_body: '<h1>BOO</h1>',
                                             track_success: false,
                                             template_id: "test"


      peleka_simulate(:open, email.id, ip: '4.3.2.1')
      email.reload

      assert_equal '4.3.2.1', email.last_open_from_ip
    end
  end
end
