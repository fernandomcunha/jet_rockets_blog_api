FactoryBot.define do
  factory :user do
    login { Faker::Lorem.unique.characters(number: 6) }
  end
end
