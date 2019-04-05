module WhiteVision
  class Sidekiq
    class AdhocEmailJob
      include Sidekiq::Worker

      def perform(email_template_id, recipient_object_id)
        email_template = EmailTemplate.find email_template_id
        recipient_object = Config.recipient_klass.find recipient_object_id

        Sender.send_adhoc_email email_template, recipient_object
      end
    end
  end
end