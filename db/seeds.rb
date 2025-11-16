# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'faker'

# シンプルなサンプルタイトル
sample_titles = [
  "今日の一曲",
  "おすすめの楽曲",
  "最近聴いている音楽",
  "お気に入りの曲",
  "リピートしている楽曲"
]

# シンプルなサンプル投稿内容
sample_descriptions = [
  "この楽曲がとても気に入っています。",
  "最近よく聴いている一曲です。",
  "友人に教えてもらった素敵な楽曲です。",
  "作業用BGMとして愛用しています。",
  "心に響く素晴らしい楽曲だと思います。"
]

# サンプル投稿データ
if defined?(Post) && defined?(User)
  users = User.all.to_a
  if users.empty?
    users << User.create!(
      name: "テストユーザー",
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )
    puts "Seed: テストユーザーを作成しました"
  end

  target_count = 50
  current_count = Post.count
  posts_to_create = [target_count - current_count, 0].max

  if posts_to_create.positive?
    posts_to_create.times do |i|
      author = users.sample
      
      Post.create!(
        user: author,
        title: "#{sample_titles.sample} ##{current_count + i + 1}",
        description: sample_descriptions.sample,
        image: "https://picsum.photos/seed/music#{i}/800/600",
        youtube_url: "https://www.youtube.com/watch?v=#{SecureRandom.alphanumeric(11)}"
      )
    end
    puts "Seed: #{posts_to_create}件のシンプルな投稿を作成しました"
  else
    puts "Seed: 投稿データは既に#{current_count}件あります"
  end
end