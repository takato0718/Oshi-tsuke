FactoryBot.define do
  factory :community_thread do
    association :user
    association :community
    description { Faker::Lorem.paragraph }
      
    trait :with_replies do
      after(:create) do |thread|
        create_list(:reply, 3, community_thread: thread)
      end
    end
  end
end
  
