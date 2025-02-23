class IncidentsController < ApplicationController
    def index
      @incidents = Incident.order(:title)
    end
  
    def resolve
      incident = Incident.find(params[:id])
      if incident.update(status: 'resolved')
        redirect_to incidents_path, notice: 'Incident resolved.'
      else
        redirect_to incidents_path, alert: 'Failed to resolve incident.'
      end
    end
end
  