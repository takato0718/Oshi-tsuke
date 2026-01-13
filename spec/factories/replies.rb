FactoryBot.define do
  factory :reply do
    association :user
    association :community_thread
    description { Faker::Lorem.paragraph }
  end
end
  
  