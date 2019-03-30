require 'white_vision/email'

module WhiteVision
  class TextEmail < Email
    def format
      :text
    end
  end
end