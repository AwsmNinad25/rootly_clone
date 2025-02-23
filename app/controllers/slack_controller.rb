class SlackController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    # Slack command handler
    def commands
      command_text = params[:text].split(' ', 2)
  
      case command_text[0]
      when 'declare'
        open_incident_modal(params[:trigger_id])
        head :ok
      when 'resolve'
        resolve_incident_in_channel(params[:channel_id])
      else
        render plain: "Unknown command", status: :ok
      end
    end
  
    # This handles the modal submission
    def interactive
      payload = JSON.parse(params[:payload]) 
      if payload["type"] == "view_submission" && payload["view"]["callback_id"] == "incident_creation_modal"
        handle_incident_submission(payload)
      end
      render json: { response_action: 'clear' }, status: :ok
    end
  
    private
  
    # Open a modal for declaring an incident
    # Open a modal for declaring an incident
    def open_incident_modal(trigger_id)
        modal_view = {
          trigger_id: trigger_id,
          view: {
            type: 'modal',
            callback_id: 'incident_creation_modal',
            title: {
              type: 'plain_text',
              text: 'Declare Incident'
            },
            submit: {                            # Add submit button here
              type: 'plain_text',
              text: 'Submit'
            },
            blocks: [
              {
                type: 'input',
                block_id: 'title_block',
                label: {
                  type: 'plain_text',
                  text: 'Incident Title'
                },
                element: {
                  type: 'plain_text_input',
                  action_id: 'title_input',
                  placeholder: {
                    type: 'plain_text',
                    text: 'Enter incident title'
                  }
                }
              },
              {
                type: 'input',
                block_id: 'description_block',
                label: {
                  type: 'plain_text',
                  text: 'Incident Description'
                },
                element: {
                  type: 'plain_text_input',
                  action_id: 'description_input',
                  placeholder: {
                    type: 'plain_text',
                    text: 'Enter description (optional)'
                  }
                }
              },
              {
                type: 'input',
                block_id: 'severity_block',
                label: {
                  type: 'plain_text',
                  text: 'Severity'
                },
                element: {
                  type: 'static_select',
                  action_id: 'severity_input',
                  placeholder: {
                    type: 'plain_text',
                    text: 'Select severity'
                  },
                  options: [
                    {
                      text: {
                        type: 'plain_text',
                        text: 'sev0'
                      },
                      value: 'sev0'
                    },
                    {
                      text: {
                        type: 'plain_text',
                        text: 'sev1'
                      },
                      value: 'sev1'
                    },
                    {
                      text: {
                        type: 'plain_text',
                        text: 'sev2'
                      },
                      value: 'sev2'
                    }
                  ]
                }
              }
            ]
          }
        }
        # Make API call to Slack
        response = HTTParty.post('https://slack.com/api/views.open', {
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{ENV['SLACK_BOT_TOKEN']}"
          },
          body: modal_view.to_json
        })
        unless response.success?
          Rails.logger.error "Error opening Slack modal: #{response['error']}"
        end
    end
      
  
    # Handle modal submission for declaring an incident
    def handle_incident_submission(payload)
        # Extract values from the modal submission using the correct keys
        title = payload.dig("view", "state", "values", "title_block", "title_input", "value")
        description = payload.dig("view", "state", "values", "description_block", "description_input", "value")
        severity = payload.dig("view", "state", "values", "severity_block", "severity_input", "selected_option", "value")
      
        # Check if the necessary fields are present to avoid nil errors
        if title.nil? || severity.nil?
          Rails.logger.error "Error: Missing title or severity in incident submission"
          render plain: "Error: Missing required fields", status: :unprocessable_entity
          return
        end
      
        # Create a private Slack channel for the incident
        channel_id = create_slack_channel(title)
      
        # Create a new incident in the database
        incident = Incident.new(
          title: title,
          description: description,
          severity: severity,
          created_by: payload.dig("user", "username"),
          slack_channel_id: channel_id,
          status: 'active',
          declared_at: Time.now
        )
      
        if incident.save
          render plain: "Incident declared: #{title}", status: :ok
        else
          render plain: "Error declaring incident", status: :unprocessable_entity
        end
    end
  
    # Create a private Slack channel for the incident
    def create_slack_channel(title)
      response = HTTParty.post("https://slack.com/api/conversations.create", 
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{ENV['SLACK_BOT_TOKEN']}"
        },
        body: {
          name: "incident-#{SecureRandom.hex(5)}",
          is_private: true
        }.to_json
      )
  
      if response['ok']
        response['channel']['id']
      else
        Rails.logger.error("Error creating Slack channel: #{response['error']}")
        nil
      end
    end
  
    # Resolve an incident in the Slack channel
    def resolve_incident_in_channel(channel_id)
      incident = Incident.find_by(slack_channel_id: channel_id, status: 'active')
  
      if incident
        incident.update(status: 'resolved', resolved_at: Time.now)
        resolution_time = distance_of_time_in_words(incident.declared_at, incident.resolved_at)
        render plain: "Incident resolved: #{incident.title}. Time to resolution: #{resolution_time}", status: :ok
      else
        render plain: "No active incidents in this channel to resolve", status: :ok
      end
    end
end
  