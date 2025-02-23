class AddDeclaredAtToIncidents < ActiveRecord::Migration[7.1]
  def change
    add_column :incidents, :declared_at, :datetime
  end
end
