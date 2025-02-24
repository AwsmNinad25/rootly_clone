class CreateSlackApps < ActiveRecord::Migration[7.1]
  def change
    create_table :slack_apps do |t|
      t.string :team_id
      t.string :access_token
      t.string :team_name

      t.timestamps
    end
  end
end
