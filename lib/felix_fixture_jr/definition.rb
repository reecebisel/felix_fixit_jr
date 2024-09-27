# frozen_string_literal: true

require_relative "null_constant"
require_relative "../felix_fixture_jr"

require "active_record"
require "pry"

module FelixFixtureJr
  module Definition
    attr_writer :file, :slug_prefix

    attr_accessor :constant,
                  :include_index,
                  :parent


    def blacklisted_attributes
      @blacklisted_attributes ||= []
    end

    def build
      File.write(path, fixtures.join, mode: "w+")
    end

    def slug_prefix
      @slug_prefix ||= [parent_name, self.class.table_name].join
    end

    def constant
      self.class.superclass
    end

    def file
      if File.exists?(path)
        File.open(path)
      else
        File.open(path, "w+")
      end
    end

    def file_size
      file.size
    end

    def path
      @path ||= [FelixFixtureJr.fixture_directory, file_name].join("/")
    end

    def fixtures
      constant.all.each_with_index.map do |instance, index|
        {
          slug(index: index, instance: instance) => filter(instance.attributes)
        }.to_yaml.gsub!("---", "")
      end
    end

    private

    def parent_name
      parent&.table_name || FelixFixtureJr.default_call_chain
    end

    def blocked_attributes
      FelixFixtureJr.blacklisted_attributes + blacklisted_attributes
    end

    def slug(index: nil, instance: nil)
      @slug ||= [slug_prefix, index].join('_')
    end

    def file_name
      @file_name ||= [constant.table_name, ".yml"].join
    end

    def filter(attributes)
      blocked_attributes.each do |attr|
        attributes.delete(attr)
      end

      attributes
    end
  end
end
