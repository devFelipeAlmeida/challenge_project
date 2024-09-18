class Notification < ApplicationRecord
  # Associações
  belongs_to :recipient, polymorphic: true, class_name: 'User'
  belongs_to :challenge

  # Validações
  validates :message, presence: true
  validates :notification_type, presence: true

  # Callback para destruir a notificação se for marcada como lida
  after_update :destroy_if_read

  private

  # Método para destruir a notificação se o status de leitura for verdadeiro
  def destroy_if_read
    destroy if read?
  end
end