class IncidentService
  def initialize(params)
    @payload = params[:payload] ? JSON.parse(params[:payload]) : {}
    @title = @payload.dig('view', 'state', 'values', 'title_block', 'title_input', 'value')
    @description = @payload.dig('view', 'state', 'values', 'description_block', 'description_input', 'value') || ''
    @severity = @payload.dig('view', 'state', 'values', 'severity_block', 'severity_input', 'selected_option', 'value') || ''
    @user_id = @payload.dig('user', 'id')
    @username = @payload.dig('user', 'username')
    @trigger_id = @payload.dig('trigger_id')
    @team_id = @payload.dig('team', 'id')
    @access_token = fetch_access_token
  end

  def declare_incident
    return { error: 'Title is required' } if @title.blank?
    return { error: 'Workspace not authorized' } unless @access_token

    # Create Slack channel
    channel_response = SlackApi.create_channel(@title, @team_id)
    channel_id = channel_response.dig('channel', 'id')

    unless channel_id
      Rails.logger.warn("Slack channel creation failed for team #{@team_id}. Response: #{channel_response}")
      return { error: 'Slack channel creation failed.' }
    end

    # Invite user to channel
    invite_response = SlackApi.invite_user(channel_id, @user_id, @team_id)
    unless invite_response['ok']
      Rails.logger.warn("Failed to invite user #{@user_id} to channel #{channel_id}. Response: #{invite_response}")
      return { error: 'Failed to invite user to Slack channel.' }
    end

    # Create incident record
    if create_incident_record(channel_id)
      { success: true }
    else
      { error: 'Failed to create incident record.' }
    end
  end

  private

  def fetch_access_token
    slack_app = SlackApp.find_by(team_id: @team_id)
    if slack_app.nil?
      Rails.logger.error("Slack workspace #{@team_id} not found in the database.")
      return nil
    elsif slack_app.access_token.blank?
      Rails.logger.error("Slack workspace #{@team_id} is missing an access token.")
      return nil
    end
    slack_app.access_token
  end

  def create_incident_record(channel_id)
    incident = Incident.new(
      title: @title,
      description: @description,
      severity: @severity,
      created_by: @username,
      slack_channel_id: channel_id,
      status: 'active',
      declared_at: Time.current
    )
    
    if incident.save
      Rails.logger.info("Incident created successfully: #{incident.id} for channel #{channel_id}")
      true
    else
      Rails.logger.error("Failed to create incident: #{incident.errors.full_messages.join(', ')}")
      false
    end
  end
end
