FactoryBot.define do
  factory :rating do
    post
    user

    value { 5 }
  end
end