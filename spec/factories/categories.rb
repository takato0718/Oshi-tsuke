FactoryBot.define do
  factory :category do
    name { Faker::Lorem.unique.word.capitalize }
    description { Faker::Lorem.sentence }
  end
end
