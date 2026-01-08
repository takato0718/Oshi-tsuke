class SeedCategories < ActiveRecord::Migration[7.0]
  def up
    # カテゴリーデータの定義
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

    puts "カテゴリーを作成中..."

    # カテゴリーを作成（重複を避けるためfind_or_create_by!を使用）
    categories_data.each do |category_data|
      Category.find_or_create_by!(name: category_data[:name]) do |category|
        category.description = category_data[:description]
      end
    end

    puts "#{Category.count}件のカテゴリーを作成しました"
  end

  def down
    # ロールバック時の処理（必要に応じて）
    # 注意: 既存のカテゴリーも削除されるので、慎重に使用してください
    puts "カテゴリーを削除中..."
    
    category_names = [
      "アニメ・漫画", "ゲーム", "音楽", "アイドル", "VTuber",
      "声優", "俳優・女優", "スポーツ", "YouTuber", "その他"
    ]
    
    Category.where(name: category_names).destroy_all
    
    puts "カテゴリーを削除しました"
  end
end