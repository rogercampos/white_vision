module WhiteVision
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    def home
      @emails = (WhiteVision::Email.descendants - [WhiteVision::TextEmail, WhiteVision::HtmlEmail]).map do |klass|
        klass.initialize_preview
      end
    end
  end
end
