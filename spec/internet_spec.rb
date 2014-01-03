require 'spec_helper'
require File.join(File.dirname(__FILE__), '..', 'internet')

describe 'The Internet' do
  it 'get /' do
    get '/'
    expect(last_response).to be_redirect
  end

  describe 'get /:address' do
    context '渋谷' do
      before do
        stub_request(:get, "http://d.hatena.ne.jp/keyword?ie=utf8&mode=rss&word=#{encoded_path}").
          to_return(open(File.join(File.dirname(__FILE__), 'fixtures', "#{encoded_path}.rss")))
      end

      let(:encoded_path) do
        URI.escape('渋谷')
      end

      it 'get /渋谷' do
        get "/#{encoded_path}"
        expect(last_response.status).to eq(200)
      end
    end

    describe 'get /サイトマップ and /最近のチェックイン' do
      %w[サイトマップ 最近のチェックイン].each do |path|
        let(:encoded_path) do
          URI.escape(path)
        end

        it do
          get "/#{encoded_path}"
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
