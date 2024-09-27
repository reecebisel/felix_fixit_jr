require "rails"
%w(
  active_record/railtie
  active_storage/engine
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_cable/engine
  action_mailbox/engine
  rails/test_unit/railtie
).each do |railtie|
  begin
      require railtie
  rescue LoadError
  end
end

require "active_support/core_ext"
require "pry"
require "sqlite3"

# Initialize our test app

class TestApp < Rails::Application
  config.active_support.deprecation = :log
  config.eager_load = false

  config.secret_token = "a" * 100

  config.root = File.expand_path("../..", __FILE__)
end

TestApp.initialize!

# Create in-memory database

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string  :name
    t.string  :email
    t.boolean :admin
  end

  create_table :companies do |t|
    t.string  :name
    t.string  :industry
    t.integer :user_id
  end

  create_table :addresses do |t|
    t.string  :street_1
    t.string  :street_2
    t.string  :city
    t.string  :state
    t.string  :zip
    t.integer :company_id
  end
end

# Define models

class ApplicationModel < ActiveRecord::Base
  self.abstract_class = true
end

class User < ApplicationModel
  has_many :companies
end

class Company < ApplicationModel
  belongs_to :user
  has_many :addresses
end

class Address < ApplicationModel
  belongs_to :company
end
