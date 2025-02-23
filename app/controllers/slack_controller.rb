class SlackController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    # Slack command handler
    def commands
      command_text = params[:text].split
  
      case command_text[0]
      when 'declare'
        declare_incident(command_text[1..-1].join(' '))
      when 'resolve'
        resolve_incident
      else
        render plain: "Unknown command", status: :ok
      end
    end
  
    private
  
    # Declare a new incident
    def declare_incident(title)
      incident = Incident.new(
        title: title,
        created_by: params[:user_name],  # Slack username
        slack_channel_id: create_slack_channel(title) # create Slack channel
      )
  
      if incident.save
        render plain: "Incident declared: #{title}", status: :ok
      else
        render plain: "Error declaring incident", status: :unprocessable_entity
      end
    end
  
    # Resolve an incident
    def resolve_incident
      incident = Incident.find_by(status: 'active')
      if incident
        incident.update(status: 'resolved')
        render plain: "Incident resolved: #{incident.title}", status: :ok
      else
        render plain: "No active incidents to resolve", status: :ok
      end
    end
  
    # Simulate Slack channel creation
    def create_slack_channel(title)
      # Placeholder for Slack API integration to create channels
      "channel_#{SecureRandom.hex(5)}"
    end
end
  