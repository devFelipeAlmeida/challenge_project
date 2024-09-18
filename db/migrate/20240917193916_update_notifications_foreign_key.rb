class UpdateNotificationsForeignKey < ActiveRecord::Migration[7.1]
  def change
    # Permitir nulos na coluna challenge_id
    change_column_null :notifications, :challenge_id, true

    # Remove a antiga restrição de chave estrangeira
    remove_foreign_key :notifications, :challenges

    # Adiciona a nova restrição de chave estrangeira com ON DELETE SET NULL
    add_foreign_key :notifications, :challenges, on_delete: :nullify
  end
end