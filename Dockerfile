FROM ruby:3.1.4

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y \
    nodejs \
    npm \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Yarnをインストール
RUN npm install -g yarn

# 作業ディレクトリを設定
WORKDIR /app

# アプリケーションのソースをコピー
COPY . .

# Gemをインストール
RUN bundle install

# Node.jsの依存関係をインストール（package.jsonがある場合）
RUN if [ -f "package.json" ]; then yarn install; fi

# ポートを公開
EXPOSE 3000

# サーバー起動
CMD ["rails", "server", "-b", "0.0.0.0"]
