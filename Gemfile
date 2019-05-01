source 'https://rubygems.org'
ruby '2.6.3'
gem 'dotenv-rails', groups: [:development, :test]
gem 'active_model_serializers', '~> 0.10.7'
gem 'amoeba',                 '~> 3.1.0'
gem 'auto_strip_attributes',  '~> 2.5.0'
gem 'aws-sdk',                '~> 2'
gem 'awesome_print'
gem 'cancancan',              '~> 1.15'
gem 'cocoon',                 '~> 1.2.6'
gem 'devise',                 '~> 4.6.2'
gem 'dry-monads',             '~> 1.2.0'
gem 'dropzonejs-rails',       '~> 0.8.2'
gem 'factory_bot_rails',      '~> 5.0.2'
gem 'faker',                  '~> 1.9.3'
gem 'googlemaps-services',    '~> 1.5.0'
gem 'gov_uk_date_fields',     '~> 3.0.0'
gem 'govuk_template',         '= 0.23.1'
gem 'govuk_frontend_toolkit', '~> 7.4.1'
gem 'govuk_elements_rails',   '~> 3.1.2'
gem 'govuk_notify_rails',     '~> 2.1.0'
gem 'grape',                  '~> 1.1.0'
gem 'grape-entity',           '~> 0.7.1'
gem 'grape-papertrail',       '~> 0.2.0'
gem 'grape-swagger',          '~> 0.32.1'
gem 'grape-swagger-rails',    '~> 0.3.0'
gem 'haml-rails',             '~> 2.0.0'
gem 'hashdiff'
gem 'hashie-forbidden_attributes', '>= 0.1.1'
gem 'jquery-rails',           '~> 4.3.3'
gem 'json-schema',            '~> 2.8.0'
gem 'nokogiri',               '~> 1.10'
gem 'kaminari',               '~> 0.17.0'
gem 'libreconv',              '~> 0.9.0'
gem 'logstasher',             '0.6.2'
gem 'logstuff',               '0.0.2'
gem 'newrelic_rpm',           '~> 6.2.0.354'
gem 'paperclip',              '~> 5.3.0'
gem 'paper_trail',            '~> 9.0.2'
gem 'pdf-forms'
gem 'pg',                     '~> 0.18.2'
gem 'rails',                  '~> 5.2.2.1'
gem 'redis',                  '~> 3.3.1'
gem 'rubyzip'
gem 'config',                 '~> 1.2' # this gem provides our Settings.xxx mechanism
gem 'remotipart',             '~> 1.2'
gem 'rest-client',            '~> 2.0' # needed for scheduled smoke testing plus others
gem 'sass-rails',             '~> 5.0.7'
gem 'scheduler_daemon',       git: 'https://github.com/jalkoby/scheduler_daemon.git'
gem 'susy',                   '~> 2.2.14'
gem 'sentry-raven',           '~> 1.2.2'
gem 'simple_form',            '~> 4.1.0'
gem 'sprockets-rails',        '~> 3.2.1'
gem 'state_machine',          '~> 1.2.0'
gem 'state_machines-activerecord'
gem 'state_machines-audit_trail'
gem 'uglifier',                '>= 1.3.0'
gem 'zendesk_api'  ,           '1.17.0'
gem 'sidekiq',                 '~> 4.2.9'
gem 'utf8-cleaner',            '~> 0.2'
gem 'colorize'
gem 'shell-spinner', '~> 1.0', '>= 1.0.4'
gem 'ruby-progressbar'
gem 'geckoboard-ruby'
gem 'posix-spawn', '~> 0.3.13'
gem 'laa-fee-calculator-client', '~> 0.2.1'

group :production, :devunicorn do
  gem 'rails_12factor', '0.0.3'
  gem 'unicorn-rails', '2.2.1'
  gem 'unicorn-worker-killer', '~> 0.4.4'
end

group :development, :devunicorn do
  gem 'meta_request'
  gem 'rubocop', '~> 0.67'
end

group :development, :devunicorn, :test do
  gem 'annotate'
  gem 'brakeman', :require => false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug'
  gem 'fuubar'
  gem 'guard-livereload',   '>= 2.5.2'
  gem 'listen',             '~> 3.1.5'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rack-livereload',    '~> 0.3.16'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'puma'
  gem 'parallel_tests'
  gem 'site_prism', '~> 3.0'
  gem 'jasmine', '~> 3.4'
  gem 'guard-jasmine', '~> 3.0'
  gem 'jasmine_selenium_runner', require: false
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-cucumber'
  gem 'net-ssh'
  gem 'net-scp'
  gem 'rubocop-rspec'
end

group :test do
  gem 'capybara', '~> 3.0'
  gem 'capybara-selenium'
  gem 'webdrivers', '~> 3.0', require: false
  gem 'climate_control'
  gem 'codeclimate-test-reporter', require: false
  gem 'cucumber-rails', '~> 1.7.0', require: false
  gem 'database_cleaner'
  gem 'json_spec'
  gem 'kaminari-rspec'
  gem 'launchy', '~> 2.4.3'
  gem 'rails-controller-testing'
  gem 'rspec-mocks'
  gem 'shoulda-matchers', '>= 4.0.0.rc1'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
  gem 'simplecov-csv', require: false
  gem 'simplecov-multi', require: false
  gem 'i18n-tasks'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
  gem 'test-prof'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end
