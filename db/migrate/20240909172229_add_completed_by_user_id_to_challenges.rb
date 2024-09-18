class AddCompletedByUserIdToChallenges < ActiveRecord::Migration[7.1]
  def change
    add_column :challenges, :completed_by_user_id, :integer
  end
end
