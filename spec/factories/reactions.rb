FactoryBot.define do
  factory :reaction do
    association :user
    association :post
    reaction_type { :like }
      
    trait :like do
      reaction_type { :like }
    end
      
    trait :comment do
      reaction_type { :comment }
    content { Faker::Lorem.paragraph }
    end
  end
end