class SlackController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    # Slack command handler
    def commands
      command_text = params[:text].split(' ', 2)
  
      case command_text[0]
      when 'declare'
        user_input = command_text[1].presence || ""
        open_incident_modal(params[:trigger_id], user_input, params[:team_id])
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
  
    def open_incident_modal(trigger_id, user_input, team_id)
      access_token = fetch_access_token(team_id)
      return render plain: "Workspace not authorized", status: :unauthorized unless access_token
  
      modal_view = IncidentModal.build(user_input)
      SlackApi.open_modal(trigger_id, modal_view, team_id)
      head :ok
    end
  
    def fetch_access_token(team_id)
      slack_app = SlackApp.find_by(team_id: team_id)
      if slack_app.nil?
        Rails.logger.error("Slack workspace #{team_id} not found in the database.")
        return nil
      elsif slack_app.access_token.blank?
        Rails.logger.error("Slack workspace #{team_id} is missing an access token.")
        return nil
      end
      slack_app.access_token
    end
  
    def incident_submission_view?
      payload = JSON.parse(params[:payload])
      payload['type'] == 'view_submission' && payload['view']['callback_id'] == 'incident_creation_modal'
    end
  
    def resolve_incident_in_channel(channel_id)
      incident = Incident.find_by(slack_channel_id: channel_id, status: 'active')
      if incident
        resolution_time = Time.now - incident.created_at
        incident.update(status: 'resolved', resolved_at: Time.now)
        render plain: "Incident resolved: #{incident.title}. Resolution time: #{format_duration(resolution_time)}.", status: :ok
      else
        render plain: 'No active incidents in this channel', status: :ok
      end
    end
  
    def format_duration(seconds)
      hours = (seconds / 3600).to_i
      minutes = ((seconds % 3600) / 60).to_i
      seconds = (seconds % 60).to_i
      "#{hours}h #{minutes}m #{seconds}s"
    end
end
  