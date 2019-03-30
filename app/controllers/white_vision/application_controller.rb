module WhiteVision
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    def home
      p EmailRecord.count
    end
  end
end
