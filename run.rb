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
post '/enter_crypto' do
  file_read   = File.read(ENV['CRYPTO'])
  json        = JSON.parse(file_read)
  crypto_type = params["crypto_type"]
  new_amount  = params["new_amount"]
  case crypto_type.to_s
  when "Bitcoin"
    if params["crypto_action"].eql?("Add")
      btc_amount = json[crypto_type.downcase]
      final  = btc_amount.to_f + new_amount.to_f
      json["bitcoin"] = final
      File.open(ENV['CRYPTO'], 'w') { |file| file.write(json.to_json) }
    elsif params["crypto_action"].eql?("Subtract")
      btc_amount = json[crypto_type.downcase]
      if btc_amount >= new_amount.to_i
        final  = btc_amount.to_f - new_amount.to_f
        json["bitcoin"] = final
        File.open(ENV['CRYPTO'], 'w') { |file| file.write(json.to_json) }
      end
    end
  when "Monero"
    if params["crypto_action"].eql?("Add")
      xmr_amount = json[crypto_type.downcase]
      final  = xmr_amount.to_f + new_amount.to_f
      json["monero"] = final
      p json
      File.open(ENV['CRYPTO'], 'w') { |file| file.write(json.to_json) }
    elsif params["crypto_action"].eql?("Subtract")
      xmr_amount = json[crypto_type.downcase]
      if xmr_amount >= new_amount.to_i
        final  = xmr_amount.to_f - new_amount.to_f
        json["monero"] = final
        File.open(ENV['CRYPTO'], 'w') { |file| file.write(json.to_json) }
      end
    end
  when "Stellar"
    if params["crypto_action"].eql?("Add")
      xlm_amount = json[crypto_type.downcase]
      final  = xlm_amount.to_f + new_amount.to_f
      json["stellar"] = final
      File.open(ENV['CRYPTO'], 'w') { |file| file.write(json.to_json) }
    elsif params["crypto_action"].eql?("Subtract")
      xlm_amount = json[crypto_type.downcase]
      if xlm_amount >= new_amount.to_i
        final  = xlm_amount.to_f - new_amount.to_f
        json["stellar"] = final
        File.open(ENV['CRYPTO'], 'w') { |file| file.write(json.to_json) }
      end
    end
  end
  erb :index
end
get '/crypto' do
  erb :crypto
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

get '/delete_bullion' do 
	erb :delete_bullion
end
get '/delete_junk' do 
	erb :delete_junk
end
get '/delete_bar' do 
	erb :delete_bar
end
get '/status_bar' do
	erb :status_bar
end
get '/status_bullion' do
	erb :status_bullion
end
get '/status_junk' do
	erb :status_junk
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
post '/delete_row' do
	inv = Inventory.new
	row_id = params.keys.shift
	case row_id.to_s
	when "delete_bar"
		inv.delete_row(params["delete_bar"], 1)
	when "delete_junk"
		inv.delete_row(params["delete_junk"], 2)
	when "delete_bullion"
		inv.delete_row(params["delete_bullion"], 3)
	end
	erb :index
end
