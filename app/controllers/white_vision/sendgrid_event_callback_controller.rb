# frozen_string_literal: true

module WhiteVision
  class SendgridEventCallbackController < ActionController::Base
    http_basic_authenticate_with name: 'secret', password: 'secret'

    def callback
      json_payload = JSON.parse request.raw_post

      EventProcessor.process(json_payload)

      head :ok
    end
  end
end