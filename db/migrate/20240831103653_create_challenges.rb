class CreateChallenges < ActiveRecord::Migration[7.1]
  def change
    create_table :challenges do |t|
      t.string :title, null: true
      t.text :description, null: true
      t.date :start_date, null: true
      t.date :end_date, null: true

      t.timestamps
    end
  end
end
