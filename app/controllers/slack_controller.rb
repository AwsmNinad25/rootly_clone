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
  
      if payload["type"] == "view_submission" && payload["view"]["callback_id"] == "incident_modal"
        handle_incident_submission(payload)
      end
    end
  
    private
  
    # Open a modal for declaring an incident
    def open_incident_modal(trigger_id)
      modal_view = {
        trigger_id: trigger_id,
        view: {
          type: "modal",
          callback_id: "incident_modal",
          title: {
            type: "plain_text",
            text: "Declare Incident"
          },
          blocks: [
            {
              type: "input",
              block_id: "title_block",
              label: {
                type: "plain_text",
                text: "Title"
              },
              element: {
                type: "plain_text_input",
                action_id: "incident_title",
                placeholder: {
                  type: "plain_text",
                  text: "Enter incident title"
                }
              }
            },
            {
              type: "input",
              block_id: "description_block",
              label: {
                type: "plain_text",
                text: "Description"
              },
              element: {
                type: "plain_text_input",
                action_id: "incident_description",
                multiline: true,
                optional: true,
                placeholder: {
                  type: "plain_text",
                  text: "Enter incident description (optional)"
                }
              }
            },
            {
              type: "input",
              block_id: "severity_block",
              label: {
                type: "plain_text",
                text: "Severity"
              },
              element: {
                type: "static_select",
                action_id: "incident_severity",
                placeholder: {
                  type: "plain_text",
                  text: "Select severity"
                },
                options: [
                  {
                    text: {
                      type: "plain_text",
                      text: "Sev0"
                    },
                    value: "sev0"
                  },
                  {
                    text: {
                      type: "plain_text",
                      text: "Sev1"
                    },
                    value: "sev1"
                  },
                  {
                    text: {
                      type: "plain_text",
                      text: "Sev2"
                    },
                    value: "sev2"
                  }
                ]
              }
            }
          ],
          submit: {
            type: "plain_text",
            text: "Submit"
          }
        }
      }
  
      response = HTTParty.post("https://slack.com/api/views.open", 
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{ENV['SLACK_BOT_TOKEN']}"
        },
        body: modal_view.to_json
      )
  
      unless response['ok']
        Rails.logger.error("Error opening Slack modal: #{response['error']}")
      end
    end
  
    # Handle modal submission for declaring an incident
    def handle_incident_submission(payload)
      # Extract values from the modal submission
      title = payload["view"]["state"]["values"]["title_block"]["incident_title"]["value"]
      description = payload["view"]["state"]["values"]["description_block"]["incident_description"]["value"]
      severity = payload["view"]["state"]["values"]["severity_block"]["incident_severity"]["selected_option"]["value"]
  
      # Create a private Slack channel for the incident
      channel_id = create_slack_channel(title)
  
      # Create a new incident in the database
      incident = Incident.new(
        title: title,
        description: description,
        severity: severity,
        created_by: payload["user"]["username"],
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
  