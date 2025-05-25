require 'sinatra'
require_relative 'test2'
require 'CryptoPriceFinder'
require 'json'
require 'dotenv/load'

set :bind, '0.0.0.0'
get '/' do
	erb :index
end
get '/test' do
	erb :test
end