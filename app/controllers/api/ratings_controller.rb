class Api::RatingsController < ApplicationController
  def create
    post = Post.find(rating_params[:post_id])
    user = User.find(rating_params[:user_id])

    begin
      Rating.transaction do
        if post.ratings.exists?(user: user)
          render json: { errors: "User has already rated this post" }, status: :unprocessable_entity and return
        end

        rating = post.ratings.create!(user: user, value: rating_params[:value])
      end

      avg_rating = post.ratings.average(:value).to_f

      render json: { average_rating: avg_rating }
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: "Post or User not found" }, status: :not_found
  end

  private

  def rating_params
    params.permit(:post_id, :user_id, :value)
  end
end
