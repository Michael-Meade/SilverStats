require 'sinatra'
require_relative 'test2'
set :bind, '0.0.0.0'
get '/' do
	erb :index
end
get '/test' do
	erb :test
end