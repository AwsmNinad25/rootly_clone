# app/services/incident_modal.rb
class IncidentModal
    def self.build
      {
        type: 'modal',
        callback_id: 'incident_creation_modal',
        title: {
          type: 'plain_text',
          text: 'Declare Incident'
        },
        submit: {
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
              },
              multiline: true
            },
            optional: true
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
              options: severity_options
            }
          }
        ]
      }
    end
  
    def self.severity_options
      [
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
    end
end
  