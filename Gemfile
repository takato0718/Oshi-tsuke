source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.4'

gem 'json', '~> 2.7'
gem 'psych', '~> 5.0'
gem 'resend'
# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.10'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'propshaft'

# Use PostgreSQL as the database for Active Record
gem 'pg', '~> 1.5'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails'

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable and cache
gem 'redis', '~> 4.0'

# Authentication (Sorcery)
gem 'sorcery', '~> 0.17.0'

# ページネーション
gem 'kaminari', '~> 1.2'

gem 'rails-i18n'

gem 'ransack', '~> 4.0'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.4'
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-matchers', '~> 5.3'
end

group :development do
  gem 'letter_opener_web'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'selenium-webdriver'
end

# gem 'dartsass-rails', '~> 0.5.0'
# gem 'sass-embedded', '~> 1.80.0'

gem 'nokogiri', '>= 1.12.0'
