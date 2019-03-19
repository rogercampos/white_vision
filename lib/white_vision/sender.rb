# frozen_string_literal: true

module WhiteVision
  module Sender
    extend self

    def api_schema
      Dry::Validation.Schema do
        required(:recipient).filled(:str?)
        required(:subject).filled(:str?)
        required(:html_body).filled(:str?)
        required(:from).filled(:str?)
        required(:track_success).filled(:bool?)
        optional(:success_rule).value(included_in?: %w[by_open by_click])
        optional(:success_url_regexp).filled(:str?)

        rule(success_present_when_tracking: %i[track_success success_rule]) do |track_success, success_rule|
          track_success.true? > success_rule.filled?
        end
      end
    end

    def send_email(data = {})
      result = api_schema.call(data)

      unless result.success?
        raise ArgumentError, "Invalid input: #{result.errors.inspect}"
      end

      email = Email.create! data.slice(:track_success, :success_rule, :success_url_regexp, :recipient, :subject, :template_id)

      send_with_sendgrid(email.id, data)

      email
    end

    private

    def send_with_sendgrid(id, data)
      # To decompose multiplexed forms like "Jon Doe <jon@gmail.com>"
      mikel_mail_from = ::Mail::Address.new(data[:from])
      mikel_mail_to = ::Mail::Address.new(data[:recipient])

      from = SendGrid::Email.new(email: mikel_mail_from.address, name: mikel_mail_from.name)
      to = SendGrid::Email.new(email: mikel_mail_to.address, name: mikel_mail_to.name)
      subject = data[:subject]
      content = SendGrid::Content.new(type: 'text/html', value: data[:html_body])
      mail = SendGrid::Mail.new(from, subject, to, content)

      mail.add_custom_arg(SendGrid::CustomArg.new(key: 'peleka_id', value: id.to_s))

      if Config.sendgrid_api_key.blank?
        raise(ArgumentError, 'There is no sendgrid api key configured!')
      end

      if Config.stub_sender
        Config.stub_sender.call(mail.to_json)

      else
        sg = SendGrid::API.new(api_key: Config.sendgrid_api_key)

        response = sg.client.mail._('send').post(request_body: mail.to_json)

        unless response.status_code == '202'
          raise "Error sending the email ##{id}" # TODO: Use custom exception
        end
      end
    end
  end
end