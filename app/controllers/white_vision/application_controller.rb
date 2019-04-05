module WhiteVision
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    def home
      @email_template_klasses = WhiteVision::Email.descendants.select {|x| x.descendants.empty? }
      @email_templates = EmailTemplate.all
    end
  end
end
