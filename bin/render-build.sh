#!/usr/bin/env bash
set -o errexit

echo "==> Installing dependencies..."
bundle install

echo "==> Precompiling assets..."
bundle exec rails assets:precompile

echo "==> Cleaning assets..."
bundle exec rails assets:clean

echo "==> Running migrations..."
bundle exec rails db:migrate

echo "==> Build completed!"