class Rating < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :value, inclusion: { in: 1..5, message: "must be between 1 and 5" }
  validates :user_id, uniqueness: { scope: :post_id, message: "can rate a post only once" }
end
