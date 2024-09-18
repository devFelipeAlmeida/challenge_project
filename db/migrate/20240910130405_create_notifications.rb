class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, polymorphic: true, null: false
      t.references :challenge, null: false, foreign_key: true
      t.string :message
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
