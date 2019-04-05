module WhiteVision
  class EmailTemplatesController < ApplicationController
    def create
      template_id = params[:email_template][:template_id]
      email_template = EmailTemplate.create! template_id: template_id,
                                             from: WhiteVision::Config.default_from

      redirect_to edit_email_template_path(email_template.id)
    end

    def edit
      @email_template = EmailTemplate.find params[:id]

      @test_recipient_email = Config.recipient_klass.find_by(Config.recipient_klass_attribute => Config.testing_only_recipients).try(Config.recipient_klass_attribute)
    end

    def update
      @email_template = EmailTemplate.find params[:id]

      @email_template.update_attributes params[:email_template].permit!
      redirect_to edit_email_template_path(@email_template.id)
    end

    def preview
      @email_template = EmailTemplate.find params[:id]
      @test_recipient = Config.recipient_klass.find_by(Config.recipient_klass_attribute => Config.testing_only_recipients)

      message = @email_template.data_for_recipient_object(@test_recipient)[:message]

      if @email_template.format == "text"
        render plain: message
      else
        render html: message.html_safe
      end
    end

    def deliver_preview
      @email_template = EmailTemplate.find params[:id]
      @test_recipient = Config.recipient_klass.find_by(Config.recipient_klass_attribute => Config.testing_only_recipients)

      ProxySender.send_adhoc_email @email_template, recipient: @test_recipient
    end
  end
end