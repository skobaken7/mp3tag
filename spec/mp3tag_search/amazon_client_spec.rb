require 'spec_helper'
require "webmock/rspec"

module Mp3tagSearch
  describe AmazonClient do
    describe '#lookup' do
      before do
        single_fixture = File::open(File::expand_path("../../fixtures/single_artist_item.xml", __FILE__)){|f| f.read}
        multi_fixture  = File::open(File::expand_path("../../fixtures/multi_artist_item.xml", __FILE__)){|f| f.read}
        none_fixture   = File::open(File::expand_path("../../fixtures/none.xml", __FILE__)){|f| f.read}

        stub_request(:any, /#{Amazon::Ecs::SERVICE_URLS[:jp]}.*ItemId=SingleArtist.*/).to_return({:body => single_fixture, :status => 200})
        stub_request(:any, /#{Amazon::Ecs::SERVICE_URLS[:jp]}.*ItemId=MultiArtist.*/).to_return({:body => multi_fixture, :status => 200})
        stub_request(:any, /#{Amazon::Ecs::SERVICE_URLS[:jp]}.*ItemId=None.*/).to_return({:body => none_fixture, :status => 200})
      end

      it 'returns valid album object if product info are found' do
        album_info = described_class.new.lookup("SingleArtist")

        expect(album_info.discs.size).to eq(1)
        expect(album_info.discs[0].tracks.size).to eq(3)

        expect(album_info.discs[0].tracks[1].no).to eq(2)
        expect(album_info.discs[0].tracks[1].title).to eq("TestTrack02")
        expect(album_info.discs[0].tracks[1].artist).to eq("Artist")
        
        expect(album_info.discs[0].no).to eq(1)
        expect(album_info.discs[0].artist).to eq("Artist")
  
        expect(album_info.title).to eq("SingleAlbumTitle")
        expect(album_info.artist).to eq("Artist")
        expect(album_info.date).to eq(Date.new(2015, 7, 7))
      end
  
      context 'when album has various artists' do
        describe 'returns album object' do
          it 'of which each track has artist info' do
            album_info = described_class.new.lookup("MultiArtist")

            expect(album_info.discs.size).to eq(2)
            expect(album_info.discs[1].tracks.size).to eq(3)

            expect(album_info.discs[1].tracks[1].no).to eq(2)
            expect(album_info.discs[1].tracks[1].title).to eq("TestTrack22")
            expect(album_info.discs[1].tracks[1].artist).to eq("TestArtist22")
            
            expect(album_info.discs[1].no).to eq(2)
            expect(album_info.discs[1].artist).to eq(MusicInfo::VARIOUS_ARTISTS)
  
            expect(album_info.title).to eq("MultiAlbumTitle")
            expect(album_info.artist).to eq(MusicInfo::VARIOUS_ARTISTS)
            expect(album_info.date).to eq(Date.new(2015, 7, 7))
          end

          it 'of which track artists are UNKNOWN when they are not found' do
            album_info = described_class.new.lookup("MultiArtist")

            expect(album_info.discs[0].tracks[2].artist).to eq(MusicInfo::UNKNOWN)
          end
        end
      end
  
      it 'returns null unless product info are found' do
        album_info = described_class.new.lookup("None")

        expect(album_info).to be_nil
      end
    end

    describe '#grepArtistFromDescription' do 
      let(:description) do
        "DISC1<br/>\n" + 
        "01 TestArtist01 / TestTrack01<br/>\n" + 
        "02 TestArtist02 / TestTrack02<br/>\n" +
        "03 TestArtist03 / TestTrack03<br/>\n"
      end

      it 'grep the track artist from description by usin regexp' do
        artist_name = described_class.new.grepArtistFromDescription(description, 2, "TestTrack02")

        expect(artist_name).to eq("TestArtist02")
      end

      it 'returns UNKWOWN when artist name is not found' do
        artist_name = described_class.new.grepArtistFromDescription(description, 1, "TestTrack02")

        expect(artist_name).to eq(MusicInfo::UNKNOWN)
      end
    end
  end
end
