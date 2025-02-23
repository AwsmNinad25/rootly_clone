class IncidentsController < ApplicationController
  def index
    @incidents = Incident.order(title: :asc).page(params[:page]).per(10)
  end
end
  