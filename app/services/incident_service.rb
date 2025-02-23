class IncidentService
  def initialize(params)
    @payload = params[:payload] ? JSON.parse(params[:payload]) : {}
    @title = @payload.dig('view', 'state', 'values', 'title_block', 'title_input', 'value')
    @description = @payload.dig('view', 'state', 'values', 'description_block', 'description_input', 'value') || ''
    @severity = @payload.dig('view', 'state', 'values', 'severity_block', 'severity_input', 'selected_option', 'value') || ''
    @user_id = @payload.dig('user', 'id')
    @trigger_id = @payload.dig('trigger_id')
  end

  def declare_incident
    # Return error if title is missing
    return { error: 'Title is required' } if @title.blank?

    # Create Slack channel and get the response
    channel_response = SlackApi.create_channel(@title)
    channel_id = channel_response.dig('channel', 'id')

    # Handle Slack channel creation failure
    unless channel_id
      Rails.logger.warn('Slack channel creation failed.')
      return { error: 'Slack channel creation failed.' }
    end

    # Invite user to the channel and create incident record
    SlackApi.invite_user(channel_id, @user_id)
    
    # Attempt to create incident record
    if create_incident_record(channel_id)
      { success: true } # Return success response
    else
      { error: 'Failed to create incident record.' }
    end
  end

  private

  def create_incident_record(channel_id)
    incident = Incident.new(
      title: @title,
      description: @description,
      severity: @severity,
      created_by: @payload.dig('user', 'username'),
      slack_channel_id: channel_id,
      status: 'active',
      declared_at: Time.current
    )
    incident.save
  end
end
