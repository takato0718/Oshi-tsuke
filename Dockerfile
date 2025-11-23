FROM ruby:3.1.4

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    nodejs \
    npm \
    imagemagick \
    libvips42 \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Yarnをインストール（jsbundling-railsで必要）
RUN npm install -g yarn

# 作業ディレクトリを設定
WORKDIR /app

# GemfileとGemfile.lockをコピー
COPY Gemfile Gemfile.lock* ./

# bundlerをインストール
RUN gem install bundler -v 2.4.22

# 依存gemをインストール
RUN bundle install

# エントリーポイントスクリプトをコピー
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# アプリケーションのコードをコピー
COPY . .

# ポートを公開
EXPOSE 3000

# エントリーポイントを設定
ENTRYPOINT ["docker-entrypoint.sh"]

# デフォルトコマンド（開発環境用）
CMD ["rails", "server", "-b", "0.0.0.0"]
