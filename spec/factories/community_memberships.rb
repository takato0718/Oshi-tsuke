FactoryBot.define do
  factory :community_membership do
    association :user
    association :community
    role { :member }
    is_active { true }
    joined_at { Time.current }
      
    trait :admin do
      role { :admin }
    end
      
    trait :moderator do
      role { :moderator }
    end
      
    trait :pending do
      is_active { false }
      joined_at { nil }
    end
  end
end
  