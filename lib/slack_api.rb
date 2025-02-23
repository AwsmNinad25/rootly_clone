# lib/slack_api.rb
class SlackApi
    BASE_URL = 'https://slack.com/api'.freeze
  
    def self.post(endpoint, body)
      response = HTTParty.post("#{BASE_URL}/#{endpoint}", {
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{ENV['SLACK_BOT_TOKEN']}"
        },
        body: body.to_json
      })
      handle_response(response)
    end
  
    def self.create_channel(title)
      post('conversations.create', { name: "incident-#{title.parameterize}-#{SecureRandom.hex(3)}", is_private: false })
    end
  
    def self.invite_user(channel_id, user_id)
      post('conversations.invite', { channel: channel_id, users: user_id })
    end
  
    def self.open_modal(trigger_id, view_payload)
      post('views.open', { trigger_id: trigger_id, view: view_payload })
    end
  
    def self.handle_response(response)
      if response.success?
        response
      else
        raise "Slack API Error: #{response['error']}"
      end
    end
end
  