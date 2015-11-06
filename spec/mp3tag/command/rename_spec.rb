require 'spec_helper'
require 'rspec/mocks'

module Mp3tag
  module Command
    describe Rename do
      describe "#common_prefix" do
        it 'returns "<cp>" when "<cp><str1>" and "<cp><str2>" passed' do
          cp = described_class.new([], "").common_prefix("abc123", "abcdef")
          expect(cp).to eq("abc")
        end

        it 'returns empty string when params start with differet strings' do
          cp = described_class.new([], "").common_prefix("123", "abc")
          expect(cp).to eq("")
        end
      end

      describe "#get_destination_name" do
        it 'replace variables in format string by corresponding frame value' do
          mp3 = double("mp3file", :tag2 => {"TIT2" => "title", "TALB" => "album"})
          result = described_class.new([], "").get_destination_name(mp3, "%TALB%-%TIT2%.mp3")
          expect(result).to eq("album-title.mp3")
        end
      end
    end
  end
end
