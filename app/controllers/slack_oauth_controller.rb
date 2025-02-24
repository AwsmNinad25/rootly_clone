class SlackOauthController < ApplicationController
    def oauth_redirect
      client_id = ENV['SLACK_CLIENT_ID']
      redirect_uri = ENV['SLACK_REDIRECT_URI']
  
      oauth_url = "https://slack.com/oauth/v2/authorize?" + URI.encode_www_form(
        client_id: client_id,
        scope: 'commands,channels:read,users:read,chat:write,channels:manage,files:read,groups:read',
        redirect_uri: redirect_uri,
      )
  
      redirect_to oauth_url, allow_other_host: true
    end
  
    def oauth_callback
      code = params[:code]
      if code.blank?
        flash[:error] = "Slack authorization failed: No code received."
        redirect_to root_path and return
      end
  
      service = SlackOauthService.new(code)
      result = service.call
  
      if result[:success]
        # Store the team_id, access_token, and team_name in your database for later use
        SlackApp.create!(
          team_id: result[:team_id],
          access_token: result[:access_token],
          team_name: result[:team_name]
        )
        
        # Optionally store the access token in the session
        session[:slack_access_token] = result[:access_token]
        
        # Redirect to Slack app page (optional)
        redirect_to "https://slack.com/app_redirect", allow_other_host: true, notice: "Successfully authenticated with Slack!"
      else
        flash[:error] = "Failed to authenticate with Slack: #{result[:error]}"
        redirect_to root_path
      end
    end
end
  