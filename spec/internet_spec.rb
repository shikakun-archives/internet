require 'spec_helper'
require File.join(File.dirname(__FILE__), '..', 'internet')

describe 'The Internet' do
  it 'GET /' do
    get '/'
    expect(last_response).to be_redirect
  end

  describe 'GET /:address' do
    context '渋谷' do
      before do
        stub_request(:get, "http://d.hatena.ne.jp/keyword?ie=utf8&mode=rss&word=#{encoded_path}").
          to_return(open(File.join(File.dirname(__FILE__), 'fixtures', "#{encoded_path}.rss")))
      end

      let(:encoded_path) do
        URI.escape('渋谷')
      end

      it 'GET /渋谷' do
        get "/#{encoded_path}"
        expect(last_response.status).to eq(200)
      end
    end

    describe 'GET /サイトマップ and /最近のチェックイン' do
      %w[サイトマップ 最近のチェックイン].each do |path|
        let(:encoded_path) do
          URI.escape(path)
        end

        it "GET /#{path}" do
          get "/#{encoded_path}"
          expect(last_response.status).to eq(200)
        end
      end
    end
  end

  describe 'POST /:address/checkin' do
    context 'Twitter 認証済み' do
      before do
        Twitter::Client.any_instance.stub(:verify_credentials).and_return(true)
      end

      context '渋谷成功' do
        before do
          stub_request(:get, "http://d.hatena.ne.jp/keyword?ie=utf8&mode=rss&word=#{encoded_path}").
            to_return(open(File.join(File.dirname(__FILE__), 'fixtures', "#{encoded_path}.rss")))
          %w[uid nickname image token secret address csrf_token].each do |key|
            Rack::Session::Abstract::SessionHash.any_instance.
              stub(:[]).with(key).and_return(key)
          end
        end

        let(:encoded_path) do
          URI.escape('渋谷')
        end

        it 'POST /渋谷/checkin' do
          expect { post "/#{encoded_path}/checkin", { csrf_token: 'csrf_token' } }.to \
            change { Checkins.count }.by(1)
        end
      end
    end
  end

  describe 'GET /auth/twitter/callback' do
    before do
      stub_request(:get, "http://d.hatena.ne.jp/keyword?ie=utf8&mode=rss&word=#{encoded_path}").
        to_return(open(File.join(File.dirname(__FILE__), 'fixtures', "#{encoded_path}.rss")))
      @auth = {'omniauth.auth' => {
        'uid'  => 'testuid',
        'info' => {
          'name'     => 'theinternet',
          'image'    => 'image',
          'nickname' => 'theinternet'
        },
        'credentials' => {
          'token'  => 'token',
          'secret' => 'secret'
        }
      }}
      # Request.envをstubにする
      # requestの中身をstubにしたいので、Sinatra::Request.any_instance〜という構文で
      # 全てのSinatra::Requestのインスタンスに対してstubできる
      Sinatra::Request.any_instance.stub(:env).and_return(@auth)
    end

    let(:encoded_path) do
      URI.escape('渋谷')
    end

    xit 'sessionにTwitterアカウント情報がセットされること' do
      get '/auth/:provider/callback'
      session['uid'].should == @auth['omniauth.auth']['uid']
    end
  end
end
