FactoryBot.define do
  factory :recommendation do
    association :user
    association :post
    status { :pending }

    trait :favorited do
      status { :favorited }
      viewed_at { Time.current }
    end

    trait :skipped do
      status { :skipped }
      skipped_at { Time.current }
      viewed_at { Time.current }
    end
  end
end
