# frozen_string_literal: true

module WhiteVision
  class SendgridEventCallbackController < ActionController::Base
    before_action do
      if Config.webhook_basic_auth_username.present? && Config.webhook_basic_auth_password.present?
        authenticate_or_request_with_http_basic("WhiteVision") do |name, password|
          ActiveSupport::SecurityUtils.secure_compare(name, Config.webhook_basic_auth_username) &
            ActiveSupport::SecurityUtils.secure_compare(password, Config.webhook_basic_auth_password)
        end
      end
    end


    def callback
      json_payload = JSON.parse request.raw_post

      EventProcessor.process(json_payload)

      head :ok

    rescue JSON::ParserError
      head :unprocessable_entity

    end
  end
end