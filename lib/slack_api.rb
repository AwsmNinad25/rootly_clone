class SlackApi
  BASE_URL = 'https://slack.com/api'.freeze

  def self.post(endpoint, body, team_id)
    access_token = fetch_access_token(team_id)
    return nil unless access_token

    response = HTTParty.post("#{BASE_URL}/#{endpoint}", {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{access_token}"
      },
      body: body.to_json
    })

    handle_response(response)
  end

  def self.create_channel(title, team_id)
    post('conversations.create', { name: "incident-#{title.parameterize}-#{SecureRandom.hex(3)}", is_private: false }, team_id)
  end

  def self.invite_user(channel_id, user_id, team_id)
    post('conversations.invite', { channel: channel_id, users: user_id }, team_id)
  end

  def self.open_modal(trigger_id, view_payload, team_id)
    post('views.open', { trigger_id: trigger_id, view: view_payload }, team_id)
  end

  private

  def self.fetch_access_token(team_id)
    return nil if team_id.blank? # Prevent querying with nil values

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

  def self.handle_response(response)
    if response.success?
      response.parsed_response
    else
      Rails.logger.error("Slack API Error: #{response.parsed_response['error']}")
      nil
    end
  end
end
