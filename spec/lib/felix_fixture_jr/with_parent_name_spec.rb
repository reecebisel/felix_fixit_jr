# frozen_string_literal: true

require "./lib/felix_fixture_jr/definition"
require "./lib/felix_fixture_jr.rb"
require "support/shared_definition"
require "spec_helper"
require "pry"

class AddressFixture < Address
  include FelixFixtureJr::Definition

  def slug(instance:, index:)
    "#{instance.company.name}_address"
  end
end

RSpec.describe AddressFixture do
  before do
    3.times do |i|
      company = Company.create(
        name: "company_#{i}",
        industry: "Totez",
        user_id: 1
      )

      Address.create(
        street_1: "Street #{i}",
        street_2: i % 2 == 0 ? nil : "Suite #{i}",
        city: "Beverly Hills",
        state: "CA",
        zip: "90210",
        company: company
      )
    end

    FelixFixtureJr.configure do |config|
      config.fixture_directory = "./spec/support"
    end
  end

  it_behaves_like "fixture definition", Address, "./spec/support/addresses.yml"

  context "custom slug name" do
    let(:subject) { described_class.new }
    let(:fixtures) { YAML.parse(subject.fixtures.join("\n")) }
    let(:keys) {%w[company_0_address company_1_address company_2_address] }
    let(:values) do
      fixtures.map { |fix| fix.instance_variable_get(:@value) }
    end

    it "has expected slugs for fixture names" do
      keys.each do |key|
        expect(values).to include(key)
      end
    end
  end
end
