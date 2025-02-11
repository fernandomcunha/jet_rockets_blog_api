require 'rails_helper'

RSpec.describe 'Api::Posts', type: :request do
  describe 'POST /api/posts' do
    let(:valid_attributes) do
      { title: 'Foo Title', body: 'Bar Body', login: 'FooBar', ip: '127.0.0.1' }
    end

    let(:invalid_attributes) do
      { title: '', body: '', login: '' }
    end

    context 'when the request is valid' do
      context 'when there is no user' do
        it 'creates a post and user' do
          expect {
            post api_posts_path, params: valid_attributes
          }.to change(Post, :count).by(1).and change(User, :count).by(1)

          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)).to include('post', 'user')
        end
      end

      context 'where there is an existing user' do
        let!(:user) { create(:user, login: valid_attributes[:login]) }

        it 'creates a post for an existing user' do
          expect {
            post api_posts_path, params: valid_attributes
          }.to change(Post, :count).by(1).and change(User, :count).by(0)

          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)).to include('post', 'user')
        end
      end
    end

    context 'when the request is invalid' do
      it 'returns an unprocessable entity status' do
        post api_posts_path, params: invalid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end
  end

  describe 'GET /api/posts/top_posts' do
    context 'when valid limit parameter is provided' do
      it 'returns the top 3 posts by average rating' do
        create_list(:user, 4) do |user|
          create_list(:post, 5, user: user) do |post|
            create(:rating, user: user, post: post, value: rand(1..5))
          end
        end

        get api_top_posts_path, params: { limit: 3 }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(3)
      end
    end

    context 'when no limit parameter is provided' do
      it 'returns the top 10 posts by average rating' do
        create_list(:user, 4) do |user|
          create_list(:post, 5, user: user) do |post|
            create(:rating, user: user, post: post, value: rand(1..5))
          end
        end

        get api_top_posts_path

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(10)
      end
    end

    context 'when invalid limit parameter is provided' do
      it 'returns the top 3 posts by average rating' do
        get api_top_posts_path, params: { limit: 'Invalid' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('errors' => 'Invalid limit parameter')
      end
    end
  end

  describe 'GET /api/posts/ips' do
    it 'returns a list of unique IPs and their respective authors' do
      create_list(:user, 2) do |user|
        create_list(:post, 3, user: user, ip: '127.0.0.1')
        create_list(:post, 2, user: user, ip: '127.0.1.1')
      end

      create_list(:user, 3) do |user|
        create_list(:post, 2, user: user, ip: '192.168.0.1')
        create_list(:post, 4, user: user, ip: '192.168.1.1')
      end

      get api_ips_path

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)

      expect(json_response.length).to eq(4)
      expect(json_response.map { |record| record['ip'] }).to match_array([ '127.0.0.1', '127.0.1.1', '192.168.0.1', '192.168.1.1' ])
      expect(json_response.find { |record| record['ip'] == '127.0.0.1' }['authors'].length).to eq(2)
      expect(json_response.find { |record| record['ip'] == '192.168.0.1' }['authors'].length).to eq(3)
    end
  end
end
