module WhiteVision
  class PreviewsController < ApplicationController
    def show
      @klass = params[:id].constantize
      @email = @klass.initialize_preview
    end
  end
end