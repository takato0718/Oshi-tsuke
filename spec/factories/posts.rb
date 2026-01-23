FactoryBot.define do
  factory :post do
    association :user
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }

    # 画像添付をスキップするかどうかを制御
    transient do
      skip_image { false }
    end

    # 画像を添付
    after(:build) do |post, evaluator|
      unless evaluator.skip_image
        post.image.attach(
          io: Rails.root.join('spec/fixtures/sample.jpg').open,
          filename: 'sample.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

    # 画像なしのトレイト
    trait :without_image do
      skip_image { true }
    end

    trait :with_categories do
      after(:create) do |post|
        post.categories << create(:category)
      end
    end

    trait :with_youtube_url do
      youtube_url { 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' }
    end
  end
end
