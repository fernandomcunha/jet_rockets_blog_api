require 'rails_helper'

RSpec.describe 'Api::Ratings', type: :request do
  describe 'POST /api/ratings' do
    let(:user) { create(:user) }
    let(:post_object) { create(:post, user:) }
    let(:valid_attributes) { { post_id: post_object.id, user_id: user.id, value: 3 } }
    let(:invalid_attributes) { { post_id: post_object.id, user_id: user.id, value: nil } }

    context 'when the request is valid' do
      it 'creates a new rating and returns the average rating' do
        expect {
          post api_ratings_path, params: valid_attributes
        }.to change(Rating, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('average_rating')
      end

      it 'returns the correct average rating' do
        create(:user) { |user| create(:rating, post: post_object, user: user, value: 5) }

        post api_ratings_path, params: valid_attributes

        expect(response).to have_http_status(:ok)
        avg_rating = JSON.parse(response.body)['average_rating']
        expect(avg_rating).to eq(4.0)
      end
    end

    context 'when the user has already rated the post' do
      before do
        create(:rating, post: post_object, user:, value: 4)
      end

      it 'does not create a new rating and returns an error' do
        expect {
          post api_ratings_path, params: valid_attributes
        }.not_to change(Rating, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('errors' => 'User has already rated this post')
      end
    end

    context 'when the request is invalid' do
      it 'returns an unprocessable entity status' do
        create(:rating, post: post_object, user:, value: 5)

        post api_ratings_path, params: invalid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'when the post or user is not found' do
      it 'returns a not found status' do
        post api_ratings_path, params: { post_id: nil, user_id: nil, value: nil }
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include('errors' => 'Post or User not found')
      end
    end
  end
end
