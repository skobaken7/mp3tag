require 'spec_helper'
require 'rspec/mocks'
require "webmock/rspec"

module Mp3tag
  describe CLI do
    describe "#expand_param_files" do
      it 'eliminates files other than mp3' do
        allow(File).to receive(:exist?){true}
        result = described_class.new.send(:expand_param_files, ["aaa.mp3", "bbb.txt", "ccc.mp3", "d.jpg"])
        expect(result).to eq(["aaa.mp3", "ccc.mp3"])
      end

      it 'raises exception when files are not found' do
        expect {
          described_class.new.send(:expand_param_files, ["aaa.mp3"])
        }.to raise_error(Mp3tag::FileNotFoundException)
      end

      it 'includes all files under the dirs' do
        allow(File).to receive(:exist?){true}
        allow(Dir).to receive(:glob){ ["a/a1.mp3", "a/a2.jpg"] }
        allow(File).to receive(:directory?).and_return(false)
        allow(File).to receive(:directory?).with("a").and_return(true)
        
        result = described_class.new.send(:expand_param_files, ["aaa.mp3", "bbb.txt", "ccc.mp3", "a"])
        expect(result).to eq(["a/a1.mp3", "aaa.mp3", "ccc.mp3"])
      end
    end
  end
end
