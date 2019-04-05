# frozen_string_literal: true

module WhiteVision
  class EmailTemplate < ActiveRecord::Base
    validates_presence_of :success_rule, if: :track_success?
    validates_inclusion_of :success_rule, in: %w[by_open by_click], allow_nil: true
    validates_inclusion_of :format, in: %w[html text], allow_nil: true
    validates_inclusion_of :status, in: %w[draft ready], allow_nil: true

    before_validation(on: :create) do
      self.status = "draft"
    end

    attr_reader :ready_to_send_errors

    def ready_to_send?
      result = Sender.api_schema.call(data.merge(recipient: "anybody@gmail.com"))

      unless result.success?
        @ready_to_send_errors = result.errors
      end

      result.success?
    end

    def data
      {
        subject: subject,
        format: format.try(:to_sym),
        message: message,
        from: from,
        template_id: template_id,
        track_success: track_success?,
        success_rule: success_rule,
        success_url_regexp: success_url_regexp
      }.select { |_, v| !v.nil? && v != "" }
    end

    def message_with_replacements
      message
    end

    # Given `recipient` is an object owned by the app, as specified in Config.recipient_klass
    def data_for_recipient_object(recipient)
      base_data = data

      base_data[:subject] = Replacements.apply(Config.replacements, base_data[:subject], object: recipient)
      replacements = { "=subject=" => base_data[:subject] }.merge(Config.replacements)

      base_data[:message] = Replacements.apply(replacements, base_data[:message], object: recipient)

      base_data[:recipient] = recipient.send(Config.recipient_klass_attribute)

      base_data
    end
  end
end
