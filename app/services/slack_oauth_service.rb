class SlackOauthService
    include HTTParty
    base_uri 'https://slack.com/api'
  
    def initialize(code)
      @code = code
      @client_id = ENV['SLACK_CLIENT_ID']
      @client_secret = ENV['SLACK_CLIENT_SECRET']
      @redirect_uri = ENV['SLACK_REDIRECT_URI']
    end
  
    def call
      response = request_access_token
      parsed_response = JSON.parse(response.body) rescue {}
  
      if response.success? && parsed_response['ok']
        { success: true, access_token: parsed_response['access_token'] }
      else
        { success: false, error: parsed_response['error'] || 'Unknown error' }
      end
    end
  
    private
  
    def request_access_token
      self.class.post('/oauth.v2.access', headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }, body: {
        client_id: @client_id,
        client_secret: @client_secret,
        code: @code,
        redirect_uri: @redirect_uri
      })
    end
end
  