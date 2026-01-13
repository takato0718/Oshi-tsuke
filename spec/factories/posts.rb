FactoryBot.define do
  factory :post do
    association :user
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    image { "https://example.com/image.jpg" }
      
    trait :with_categories do
      after(:create) do |post|
        post.categories << create(:category)
      end
    end
      
    trait :with_youtube_url do
      youtube_url { "https://www.youtube.com/watch?v=dQw4w9WgXcQ" }
    end
  end
end
  