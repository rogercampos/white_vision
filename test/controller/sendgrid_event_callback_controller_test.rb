require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
  include TestHelpers

  test "with bad payload" do
    post "/white_vision/sendgrid-event-callback"
    assert_response :unprocessable_entity

    post "/white_vision/sendgrid-event-callback", params: 'foobar=23'
    assert_response :unprocessable_entity
  end

  test 'with correct json payload but invalid data' do
    post "/white_vision/sendgrid-event-callback", params: '{"foo": "bar", "bool": true}'
    assert_response :success

    post "/white_vision/sendgrid-event-callback", params: '[{"foo": "bar", "bool": true}]'
    assert_response :success
  end

  test 'returns 403 if basic auth is enabled' do
    use_config webhook_basic_auth_username: "foo", webhook_basic_auth_password: "bar"

    incorrect_creds = ActionController::HttpAuthentication::Basic.encode_credentials("foo", "incorrect")
    post "/white_vision/sendgrid-event-callback",
         params: '[{"foo": "bar", "bool": true}]',
         headers: { "HTTP_AUTHORIZATION" => incorrect_creds }

    assert_response :unauthorized

    correct_creds = ActionController::HttpAuthentication::Basic.encode_credentials("foo", "bar")
    post "/white_vision/sendgrid-event-callback",
         params: '[{"foo": "bar", "bool": true}]',
         headers: { "HTTP_AUTHORIZATION" => correct_creds }

    assert_response :success
  end
end
