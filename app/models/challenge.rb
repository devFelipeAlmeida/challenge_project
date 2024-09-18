class Challenge < ApplicationRecord
  belongs_to :user, optional: true, foreign_key: :completed_by_user_id
  validates :title, presence: true
  validates :description, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  validates :status, inclusion: { in: %w[active completed approved ] }

  has_many :notifications
  has_many :comments, dependent: :destroy

  scope :active, -> { where("start_date <= ? AND end_date >= ?", Date.today, Date.today) }
  scope :upcoming, -> { where("start_date > ?", Date.today) }
end
