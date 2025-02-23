class SlackController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    # Slack command handler
    def commands
      command_text = params[:text].split(' ', 2)
  
      case command_text[0]
      when 'declare'
        open_incident_modal(params[:trigger_id])
      when 'resolve'
        resolve_incident_in_channel(params[:channel_id])
      else
        render plain: 'Unknown command', status: :ok
      end
    end
  
    def interactive
      if incident_submission_view?
        incident_service = IncidentService.new(params)
        result = incident_service.declare_incident
        if result[:error]
          render plain: result[:error], status: :unprocessable_entity
        else
          render json: { response_action: 'clear' }, status: :ok
        end
      else
        render json: { response_action: 'clear' }, status: :ok
      end
    end
  
    private
  
    def open_incident_modal(trigger_id)
      modal_view = IncidentModal.build
      SlackApi.open_modal(trigger_id, modal_view)
      head :ok
    end
  
    def incident_submission_view?
      payload = JSON.parse(params[:payload])
      payload['type'] == 'view_submission' && payload['view']['callback_id'] == 'incident_creation_modal'
    end
  
    def resolve_incident_in_channel(channel_id)
      incident = Incident.find_by(slack_channel_id: channel_id, status: 'active')
      if incident
        incident.update(status: 'resolved', resolved_at: Time.now)
        render plain: "Incident resolved: #{incident.title}.", status: :ok
      else
        render plain: 'No active incidents in this channel', status: :ok
      end
    end
end
  