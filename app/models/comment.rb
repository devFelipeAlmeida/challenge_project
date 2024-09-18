class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :challenge

  validates :content, presence: true
end
