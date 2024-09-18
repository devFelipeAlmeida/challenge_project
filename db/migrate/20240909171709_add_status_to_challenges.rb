class AddStatusToChallenges < ActiveRecord::Migration[7.1]
  def change
    add_column :challenges, :status, :string, default: 'active'
  end
end
