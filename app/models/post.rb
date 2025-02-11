class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings

  validates :title, :body, :ip, presence: true

  scope :top_posts_by_avg_rating, ->(n) {
    joins(:ratings)
    .select("posts.*, AVG(ratings.value) AS average_rating")
    .group(:id)
    .order(average_rating: :desc)
    .limit(n)
  }
  scope :ips_posted_by_diff_authors, -> {
    joins(:user)
    .select("posts.ip, users.login")
    .group("posts.ip, users.login")
  }
end
