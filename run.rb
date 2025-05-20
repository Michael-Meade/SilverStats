require 'sinatra'
require_relative 'test2'

get '/' do
	erb :index
end