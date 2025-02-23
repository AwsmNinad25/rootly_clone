class CreateIncidents < ActiveRecord::Migration[7.1]
  def change
    create_table :incidents do |t|
      t.string :title, null: false
      t.text :description
      t.string :severity, default: 'sev2'
      t.string :status, default: 'active'
      t.string :created_by
      t.string :slack_channel_id

      t.timestamps
    end
  end
end
