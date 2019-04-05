module WhiteVision
  module ProxySender

    extend self


    def send_adhoc_email(email_template, recipient:)
      case Config.background_adapter
        when :sidekiq
          require 'white_vision/sidekiq'
          WhiteVision::Sidekiq::AdhocEmailJob.perform_async email_template.id, recipient.id

        when nil
          Sender.send_adhoc_email email_template, recipient

      end
    end
  end
end