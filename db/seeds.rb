require 'faker'
require 'httparty'

USER_COUNT = 100
POST_COUNT = 200_000
IP_ADDRESSES = Array.new(50) { Faker::Internet.unique.ip_v4_address }
RATING_PROBABILITY = 0.75

def create_post(login, ip)
  response = HTTParty.post(
    'http://localhost:3000/api/posts', 
    headers: { 'Content-Type' => 'application/json' },
    body: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph, login: login, ip: ip }.to_json
  )

  JSON.parse(response.body)['post']['id']
end

def create_rating(post_id, user_id, value)
  HTTParty.post(
    'http://localhost:3000/api/ratings', 
    headers: { 'Content-Type' => 'application/json' },
    body: { post_id: post_id, user_id: user_id, value: value }.to_json
  )
end

users = Array.new(USER_COUNT) { Faker::Lorem.unique.characters(number: 6) }

POST_COUNT.times do |i|
  login = users.sample
  ip = IP_ADDRESSES.sample
  post_id = create_post(login, ip)

  if rand < RATING_PROBABILITY
    rating_user_id = User.find_by(login: login).id
    create_rating(post_id, rating_user_id, rand(1..5))
  end

  puts "Created #{i + 1} posts" if (i + 1) % 5_000 == 0
end

puts 'Done!'