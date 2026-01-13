FactoryBot.define do
  factory :community do
    association :creator, factory: :user
    name { Faker::Lorem.unique.word.capitalize + " Community" }
    description { Faker::Lorem.paragraph }
    is_public { true }
      
    trait :private do
      is_public { false }
    end
      
    trait :with_members do
      after(:create) do |community|
        create_list(:community_membership, 3, community: community)
      end
    end
      
    trait :with_threads do
      after(:create) do |community|
        create_list(:community_thread, 2, community: community)
      end
    end
  end
end