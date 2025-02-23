class AddResolvedAtAndResolutionTimeToIncidents < ActiveRecord::Migration[7.1]
  def change
    add_column :incidents, :resolved_at, :datetime
    add_column :incidents, :resolution_time, :string
  end
end
