require 'rubygems'
require 'bundler'
Bundler.require

Dotenv.load

require './internet.rb'
run Sinatra::Application
