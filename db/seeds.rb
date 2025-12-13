# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require "faker"
require "securerandom"

# カテゴリのシードデータ
if defined?(Category)
  categories_data = [
    { name: "アニメ・漫画", description: "アニメや漫画のキャラクター" },
    { name: "ゲーム", description: "ゲームキャラクターやゲーム関連" },
    { name: "音楽", description: "アーティストやバンド" },
    { name: "アイドル", description: "アイドルグループや個人" },
    { name: "VTuber", description: "バーチャルYouTuber" },
    { name: "声優", description: "声優" },
    { name: "俳優・女優", description: "俳優や女優" },
    { name: "スポーツ", description: "スポーツ選手" },
    { name: "YouTuber", description: "YouTuberや配信者" },
    { name: "その他", description: "その他の推し" }
  ]

  categories_data.each do |cat_data|
    Category.find_or_create_by!(name: cat_data[:name]) do |category|
      category.description = cat_data[:description]
    end
  end
  puts "Seed: カテゴリデータを作成しました"
end

# Sorcery用 初期ユーザー
if defined?(User)
  unless User.exists?(email: "demo@example.com")
    User.create!(
      name: "Demo User",
      email: "demo@example.com",
      password: "password",
      password_confirmation: "password"
    )
    puts "Seed: Demo user created (demo@example.com / password)"
  else
    puts "Seed: Demo user already exists"
  end
end

# サンプル投稿データ
if defined?(Post) && defined?(User)
  users = User.all.to_a
  if users.empty?
    users << User.create!(
      name: "Sample Author",
      email: "author@example.com",
      password: "password",
      password_confirmation: "password"
    )
    puts "Seed: Sample author created (author@example.com / password)"
  end

  target_count = 50
  current_count = Post.count
  posts_to_create = [target_count - current_count, 0].max

  if posts_to_create.positive?
    posts_to_create.times do |i|
      author = users.sample
      Post.create!(
        user: author,
        title: "#{Faker::Music::RockBand.name}の推し ##{current_count + i + 1}",
        description: Faker::Lorem.paragraphs(number: 3).join("\n\n"),
        image: "https://picsum.photos/seed/#{SecureRandom.hex(4)}/800/600.jpg",
        youtube_url: "https://www.youtube.com/watch?v=#{SecureRandom.alphanumeric(11)}"
      )
    end
    puts "Seed: #{posts_to_create}件のサンプル投稿を作成しました"
  else
    puts "Seed: 投稿データは既に#{current_count}件あります（追加作成なし）"
  end
end