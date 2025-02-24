class ApplicationController < ActionController::Base
    rescue_from ActionController::RoutingError, with: :render_404


    def render_404
        respond_to do |format|
          format.html { render 'errors/404', status: :not_found }
          format.json { head :not_found }
        end
    end

end
