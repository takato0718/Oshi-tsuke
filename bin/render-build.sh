#!/usr/bin/env bash
set -o errexit

echo "==> Installing Ruby dependencies..."
bundle install

echo "==> Installing Node.js dependencies..."
yarn install

echo "==> Building JavaScript with esbuild..."
yarn build

echo "==> Precompiling Rails assets..."
bundle exec rails assets:precompile

echo "==> Cleaning old assets..."
bundle exec rails assets:clean

echo "==> Running database migrations..."
bundle exec rails db:migrate

echo "==> Build completed!"
