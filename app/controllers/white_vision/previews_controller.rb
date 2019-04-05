module WhiteVision
  class PreviewsController < ApplicationController
    def show
      @klass = params[:id].constantize
      @email = @klass.initialize_preview

      render layout: false
    end
  end
end