# frozen_string_literal: true

require 'sinatra'
require_relative 'test2'
require 'CryptoPriceFinder'
require 'json'
require 'dotenv'
require 'gruff'

Dotenv.load('local.env')

set :bind, '100.76.208.14'
# set :port, 80
get '/' do
  erb :index
end
get '/bar' do
  erb :bar
end
post '/enter_bar' do
  i = Inventory.new
  # 1: Bar
  i.input_site(1, params)
  erb :index
end
get '/junk' do
  erb :junk
end
post '/enter_junk' do
  i = Inventory.new
  # 2: junk
  i.input_site(2, params)
  erb :index
end
get '/bullion' do
  erb :bullion
end
post '/enter_bullion' do
  i = Inventory.new
  # 3: bullion
  i.input_site(3, params)
  erb :index
end
get '/test' do  
	erb :test
end
post '/status' do
  inv = Inventory.new
  # Get the type name
  # example: status_bar
  type_key = params.keys.shift
  case type_key.to_s
  when 'status_bar'
    # get row id
    row_id = params['status_bar'].to_s
    inv.update_own(row_id, 1, website: true, sold_price: params['sold_price'].to_s)
  when 'status_junk'
    # get row id
    row_id = params['status_junk'].to_s
    inv.update_own(row_id, 2, website: true, sold_price: params['sold_price'].to_s)
  when 'status_bullion'
    # get row id
    row_id = params['status_bullion'].to_s
    inv.update_own(row_id, 3, website: true, sold_price: params['sold_price'].to_s)
  end
  erb :index
end
