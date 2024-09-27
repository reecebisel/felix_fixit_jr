# frozen_string_literal: true

RSpec.shared_examples "fixture definition" do |constant, expect_fixture_path|
  context "minimal setup for class" do
    let(:prefix) do
      File.basename(expect_fixture_path).gsub(".yml", "")
    end

    before do
      @subject = described_class.new
    end

    after do
      File.write(@subject.file.path, "", mode: "w")
      constant.destroy_all
    end

    it "#slug_prefix" do
      expect(@subject.slug_prefix).to eq(prefix)
    end

    it "#file" do
      expect(
        FileUtils.identical?(@subject.file, File.open(expect_fixture_path))
      ).to be true
    end

    it "#fixtures" do
      expect(@subject.fixtures.length).to eq(3)

      @subject.fixtures.each do |fixture|
        expect(YAML.parse(fixture))
      end
    end

    it "#build" do
      expect(@subject.file_size).to eq 0
      @subject.build
      expect(@subject.file_size).to be > 0
    end

    it "#build creates new fixture file" do
      File.delete(@subject.file)

      expect(@subject.file_size).to eq 0
      @subject.build
      expect(@subject.file_size).to be > 0
    end

    it "#constant" do
      expect(@subject.constant).to eq(constant)
    end
  end
end
