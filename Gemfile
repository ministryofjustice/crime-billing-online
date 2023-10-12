source 'https://rubygems.org'
ruby '3.1.4'
gem 'active_model_serializers', '~> 0.10.14'
gem 'amoeba',                 '~> 3.3.0'
gem 'auto_strip_attributes',  '~> 2.6.0'
gem 'aws-sdk-s3',             '~> 1'
gem 'aws-sdk-sns',            '~> 1'
gem 'aws-sdk-sqs',            '~> 1'
gem 'awesome_print'
gem 'bootsnap', require: false
gem 'cancancan',              '~> 3.5'
gem 'cocoon',                 '~> 1.2.15'
gem 'devise', '~> 4.9.2'
gem 'dotenv-rails'
gem 'factory_bot_rails', '~> 6.2.0'
gem 'faker',                  '~> 3.2.1'
gem 'govuk_design_system_formbuilder', '~> 4.1'
gem 'govuk_notify_rails', '~> 2.2.0'
gem 'grape', '~> 1.8.0'
gem 'grape-entity',           '~> 1.0.0'
gem 'grape-papertrail',       '~> 0.2.0'
gem 'grape-swagger', '~> 1.6.1'
gem 'grape-swagger-rails', '~> 0.4.0'
gem 'haml-rails', '~> 2.1.0'
gem 'hashdiff',               '>= 1.0.0.beta1', '< 2.0.0'
gem 'hashie-forbidden_attributes', '>= 0.1.1'
gem 'jquery-rails', '~> 4.6.0'
gem 'json-schema',            '~> 4.1.1'
gem 'jsbundling-rails'
gem 'nokogiri',               '~> 1.15'
gem 'kaminari',               '>= 1.2.1'
gem 'libreconv',              '~> 0.9.5'
gem 'logstasher',             '2.1.5'
gem 'logstuff',               '0.0.2'
gem 'net-imap'
gem 'net-pop'
gem 'net-smtp'
gem 'paper_trail', '~> 15.0.0'
gem 'pg',                     '~> 1.5.4'
gem 'rails', '~> 6.1.7'
gem 'redis',                  '~> 5.0.7'
gem 'rubyzip'
gem 'config',                 '~> 4.2' # this gem provides our Settings.xxx mechanism
gem 'remotipart',             '~> 1.4'
gem 'rest-client',            '~> 2.1' # needed for scheduled smoke testing plus others
gem 'scheduler_daemon'
gem 'sentry-rails', '~> 5.12'
gem 'sentry-sidekiq', '~> 5.12'
gem 'sprockets-rails', '~> 3.4.2'
gem 'state_machines-activerecord'
gem 'state_machines-audit_trail'
gem 'tzinfo-data'
gem 'zendesk_api'  ,           '1.37.0'
gem 'sidekiq', '~> 7.1'
gem 'sidekiq-failures', '~> 1.0', '>= 1.0.4'
gem 'utf8-cleaner',            '~> 1.0'
gem 'colorize'
gem 'shell-spinner', '~> 1.0', '>= 1.0.4'
gem 'ruby-progressbar'
gem 'geckoboard-ruby'
gem 'laa-fee-calculator-client', '~> 1.4'
gem 'active_storage_validations'
gem 'faraday', '~> 1.10'
gem 'faraday_middleware', '~> 1.2'

group :production, :devunicorn do
  gem 'unicorn-rails', '2.2.1'
  gem 'unicorn-worker-killer', '~> 0.4.5'
end

group :development, :devunicorn, :test do
  gem 'annotate'
  gem 'brakeman', :require => false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug'
  gem 'listen', '~> 3.8.0'
  gem 'meta_request'
  gem 'parallel_tests'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'puma'
  gem 'rack-livereload', '~> 0.5.1'
  gem 'rspec-rails', '~> 6.0.3'
  gem 'rspec-collection_matchers'
  gem 'rspec_junit_formatter'
  gem 'net-ssh', '~> 7.2'
  gem 'net-scp', '~> 4.0'
  gem 'rubocop', '~> 1.57'
  gem 'rubocop-capybara', '~> 2.19'
  gem 'rubocop-factory_bot', '~> 2.24'
  gem 'rubocop-rspec', '~> 2.24'
  gem 'rubocop-rails', '~> 2.21'
  gem 'rubocop-performance', '~> 1.19'
  gem 'site_prism', '~> 4.0'
end

group :test do
  gem 'axe-core-cucumber', '~> 4.8'
  gem 'capybara-selenium'
  gem 'capybara', '~> 3.39'
  gem 'cucumber-rails', '~> 2.6.1', require: false
  gem 'database_cleaner'
  gem 'i18n-tasks'
  gem 'json_spec'
  gem 'launchy', '~> 2.5.2'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers', '~> 0.10.0'
  gem 'rspec-mocks'
  gem 'shoulda-matchers', '~> 5.3'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
