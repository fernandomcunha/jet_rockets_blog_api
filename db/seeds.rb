require 'faker'
require 'httparty'
require 'parallel'

USER_COUNT = 100
POST_COUNT = 200_000
IP_ADDRESSES = Array.new(50) { Faker::Internet.unique.ip_v4_address }
RATING_PROBABILITY = 0.75
THREAD_COUNT = 3
RETRY_LIMIT = 3

def retries(limit, model)
  attempts = 0
  begin
    yield
  rescue StandardError => e
    attempts += 1
    retry_attempt = attempts < limit
    puts "Error creating #{model}: #{e.message}. Retrying..." if retry_attempt
    retry if retry_attempt
  end
end

def create_post(login, ip)
  retries(RETRY_LIMIT, 'post') do
    response = HTTParty.post(
      'http://localhost:3000/api/posts',
      headers: { 'Content-Type' => 'application/json' },
      body: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph, login: login, ip: ip }.to_json
    )

    JSON.parse(response.body)['post']['id']
  end
end

def create_rating(post_id, user_id, value)
  retries(RETRY_LIMIT, 'rating') do
    HTTParty.post(
      'http://localhost:3000/api/ratings',
      headers: { 'Content-Type' => 'application/json' },
      body: { post_id: post_id, user_id: user_id, value: value }.to_json
    )
  end
end

users = Array.new(USER_COUNT) { Faker::Lorem.unique.characters(number: 6) }
user_ids = users.each_with_object({}) do |login, hash|
  user = User.create!(login: login)
  hash[login] = user.id
end

Parallel.each(1..POST_COUNT, in_threads: THREAD_COUNT) do |i|
  user_login = users.sample
  user_id = user_ids[user_login]
  ip = IP_ADDRESSES.sample

  post_id = create_post(user_login, ip)

  create_rating(post_id, user_id, rand(1..5)) if post_id && rand < RATING_PROBABILITY

  puts "Created #{i} posts" if i % 5000 == 0
end

puts 'Seeding completed!'

# require 'faker'
# require 'httparty'
#
# USER_COUNT = 100
# POST_COUNT = 200_000
# IP_ADDRESSES = Array.new(50) { Faker::Internet.unique.ip_v4_address }
# RATING_PROBABILITY = 0.75
#
# def create_post(login, ip)
#   response = HTTParty.post(
#     'http://localhost:3000/api/posts',
#     headers: { 'Content-Type' => 'application/json' },
#     body: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph, login: login, ip: ip }.to_json
#   )
#
#   JSON.parse(response.body)['post']['id']
# end
#
# def create_rating(post_id, user_id, value)
#   HTTParty.post(
#     'http://localhost:3000/api/ratings',
#     headers: { 'Content-Type' => 'application/json' },
#     body: { post_id: post_id, user_id: user_id, value: value }.to_json
#   )
# end
#
# users = Array.new(USER_COUNT) { Faker::Lorem.unique.characters(number: 6) }
# user_ids = users.each_with_object({}) do |login, hash|
#   user = User.create!(login: login)
#   hash[login] = user.id
# end
#
# POST_COUNT.times do |i|
#   user_login = users.sample
#   user_id = user_ids[user_login]
#   ip = IP_ADDRESSES.sample
#
#   post_id = create_post(user_login, ip)
#
#   create_rating(post_id, user_id, rand(1..5)) if post_id && rand < RATING_PROBABILITY
#
#   puts "Created #{i} posts" if i % 5000 == 0
# end
#
# puts 'Done!'
