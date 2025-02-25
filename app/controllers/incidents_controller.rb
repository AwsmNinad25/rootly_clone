class IncidentsController < ApplicationController
  def index
    sort_order = params[:sort_order] || 'asc'
    @incidents = Incident
                   .select(:id, :title, :severity, :description, :status, :created_by)
                   .order(title: sort_order)
                   .page(params[:page])
                   .per(10)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
