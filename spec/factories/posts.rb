FactoryBot.define do
  factory :post do
    user
    
    title { "Foo" }
    body { "Foo Bar Foo Bar" }
    ip { "127.0.0.1" }
  end
end