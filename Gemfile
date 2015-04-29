source 'https://rubygems.org'

gem 'rails', '~> 4.2.1'
gem 'responders'
gem 'sprockets', '~> 2.12'
gem 'mysql2'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'state_machine'
gem 'resque', '1.26.pre.0'
gem 'redis-rails'
gem 'thin'
gem 'octokit'
gem 'faker'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'safe_yaml', require: 'safe_yaml/load'
gem 'airbrake', '~> 3.1.5'
gem 'pubsubstub', '~> 0.0.7'
gem 'securecompare', '~>1.0'
gem 'rails-timeago', '~> 2.0'
gem 'ansi_stream', github: 'byroot/ansi_stream', ref: '5c5324ace533b819eadc8d1ae8b022138ac4a5eb', branch: 'strip'
gem 'heroku'
gem 'faraday'
gem 'faraday-http-cache'
gem 'validate_url'
gem 'active_model_serializers'
gem 'explicit-parameters'
gem 'rack-cors', require: 'rack/cors'
gem 'react-rails', github: 'byroot/react-rails', branch: 'dont-crash-on-boot-because-of-file-copying', ref: '07eec911ed957e724ef996fd30ae055ec858dd31'
gem 'redis-objects'

group :development do
  gem 'quiet_assets'
end

group :development, :test do
  gem 'foreman', '~> 0.74'
  gem 'rubocop'
end

group :test do
  gem 'fakeweb'
  gem 'test_after_commit'
  gem 'mocha'
  gem 'simplecov', require: false
end

group :debug do
  gem 'byebug'
  gem 'pry'
end

group :deploy do
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano'
  gem 'whenever'
end
