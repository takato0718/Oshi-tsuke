#!/bin/bash
set -e

# 既存のPIDファイルを削除
rm -f /app/tmp/pids/server.pid

# データベースが起動するまで待機（Docker Compose環境の場合のみ）
if [ -n "$DATABASE_HOST" ] && [ "$DATABASE_HOST" != "localhost" ]; then
  echo "Waiting for database to be ready..."
  until pg_isready -h "$DATABASE_HOST" -U "$DATABASE_USERNAME" >/dev/null 2>&1; do
    echo "Database is unavailable - sleeping"
    sleep 2
  done
  echo "Database is up - executing command"
fi

# データベースのセットアップ（初回のみ）
if [ "$RAILS_ENV" != "test" ]; then
  if ! rails db:version 2>/dev/null; then
    echo "Setting up database..."
    rails db:create 2>/dev/null || true
    rails db:migrate
    echo "Database setup complete"
  else
    echo "Running pending migrations..."
    rails db:migrate 2>/dev/null || true
  fi
fi

# アセットのプリコンパイル（本番環境の場合）
if [ "$RAILS_ENV" = "production" ]; then
  rails assets:precompile
fi

# 引数として渡されたコマンドを実行
exec "$@"
