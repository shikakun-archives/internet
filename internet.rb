# coding: utf-8

Sequel::Model.plugin(:schema)

db = {
  user:     ENV['USER'],
  dbname:   ENV['DBNAME'],
  password: ENV['PASSWORD'],
  host:     ENV['HOST']
}

configure :development do
  DB = Sequel.connect("sqlite://checkins.db")
end

configure :production do
  DB = Sequel.connect("mysql2://#{db[:user]}:#{db[:password]}@#{db[:host]}/#{db[:dbname]}")
end

class Users < Sequel::Model
  unless table_exists?
    set_schema do
      primary_key :id
      String :uid
      String :nickname
      String :image
      String :token
      String :secret
      String :address
    end
    create_table
  end
end

use Rack::Session::Cookie,
  :key => 'rack.session',
  :path => '/',
  :expire_after => 3600,
  :secret => ENV['SESSION_SECRET']

use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
end

not_found do
  "404"
end

def tweet(tweets)
  if settings.environment == :production
    twitter_client = Twitter::Client.new
    twitter_client.update(tweets)
  elsif settings.environment == :development
    flash.next[:info] = tweets
  end
  
  Twitter.configure do |config|
    config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
    config.oauth_token        = session['token']
    config.oauth_token_secret = session['secret']
  end
end

get "/" do
  redirect "/%e6%b8%8b%e8%b0%b7"
end

get "/:address" do
  session['address'] = @params[:address]
  slim :index
end

get "/auth/:provider/callback" do
  auth = request.env["omniauth.auth"]
  session['uid'] = auth['uid']
  session['nickname'] = auth['info']['nickname']
  session['image'] = auth['info']['image']
  session['token'] = auth['credentials']['token']
  session['secret'] = auth['credentials']['secret']
  tweet(session['nickname'] + " はインターネットの" + session['address'] + "にいます")
  redirect "/"
end
