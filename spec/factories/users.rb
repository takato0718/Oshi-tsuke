FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Test User #{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }

    transient do
      is_oauth_user { false }
    end

    # OAuth関連の属性(デフォルトはnil)
    provider { nil }
    uid { nil }
    avatar_url { nil }

    # パスワードはOAuthユーザーでない場合のみ設定
    password { is_oauth_user ? nil : 'password123' }
    password_confirmation { is_oauth_user ? nil : 'password123' }

    # 投稿を持つユーザー
    trait :with_posts do
      after(:create) do |user|
        create_list(:post, 3, user: user)
      end
    end

    # コミュニティを持つユーザー
    trait :with_communities do
      after(:create) do |user|
        create_list(:community, 2, creator: user)
      end
    end

    # OAuth認証ユーザー(パスワードなし)
    trait :with_oauth do
      is_oauth_user { true }
      provider { 'google_oauth2' }
      sequence(:uid) { |n| "oauth_uid_#{n}" }
      avatar_url { 'https://example.com/avatar.jpg' }
    end
  end
end
