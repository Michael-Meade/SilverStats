# frozen_string_literal: true

require 'sinatra'
require 'colorize'
require_relative 'lib'
require 'securerandom'
begin
  require 'CryptoPriceFinder'
rescue => e
  puts e.red
end
require 'json'
require 'dotenv'
require 'gruff'
require 'digest'


Dotenv.load('local.env')

#set :bind, '0.0.0.0'
set :port, 8080
use Rack::Logger
configure do
  class ::Logger; alias_method :write, :<<; end
  use Rack::CommonLogger, Logger.new('app.log')
end


use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == ['admin', ENV['PASS'] ]  
end
get '/' do
  erb :index
end
get '/bar' do
  erb :bar
end
get '/dns' do
  erb :dns
end
post '/enter_bar' do
  i = Inventory.new
  # 1: Bar
  quantity = params["quantity"].to_i
  if quantity > 0
    quantity.times { |ii| i.input_site(1, params) }
  else
    i.input_site(1, params)
  end
  erb :index
end
post '/enter_gold' do
  i = Inventory.new
  # 5: gold
  i.input_site(5, params)
  erb :index
end

post '/enter_dns' do
  i = Inventory.new
  # 6: Do Not Sell
  i.input_site(6, params)
  erb :index
end
get '/gold' do
  erb :gold
end
get '/junk' do
  erb :junk
end
post '/enter_cash' do
  i = Inventory.new
  i.input_cash(params, html: true)
  erb :index
end
get '/cash' do
  erb :cash
end
post '/enter_crypto' do
  file_read   = File.read(ENV['CRYPTO'])
  json        = JSON.parse(file_read)
  crypto_type = params["crypto_type"]
  new_amount  = params["new_amount"]
  case crypto_type.to_s
  when "Bitcoin"
    # add an amount to the bitcoin current amount
    if params["crypto_action"].eql?("Add")
      btc_amount = json[crypto_type.downcase]
      final  = btc_amount.to_f + new_amount.to_f
      json["bitcoin"] = final
      File.open(ENV['CRYPTO'], 'w') { |file| file.write(json.to_json) }
    # subtract from the current amount
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
      # update the monero key with the final amount 
      json["monero"] = final
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
      # update the stellar key
      json["stellar"] = final
      # save the newly updated hash to a file
      File.open(ENV['CRYPTO'], 'w') { |file| file.write(json.to_json) }
    elsif params["crypto_action"].eql?("Subtract")
      xlm_amount = json[crypto_type.downcase]
      if xlm_amount >= new_amount.to_i
        # subtract the current xlm amount minus the new_amount
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
get '/delete_cash' do
  erb :delete_cash 
end
get '/delete_bar' do 
	erb :delete_bar
end
get '/delete_dns' do 
  erb :delete_dns
end
get '/delete_gold' do 
  erb :delete_gold
end
get '/status_bar' do
	erb :status_bar
end
get '/status_bullion' do
	erb :status_bullion
end
get '/status_cash' do 
  erb :status_cash
end
get '/status_junk' do
	erb :status_junk
end
get '/status_gold' do 
  erb :status_gold
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
    # update own by using row_id
    inv.update_own(row_id, 1, website: true, sold_price: params['sold_price'].to_s)
  when 'status_junk'
    # get row id for junk
    row_id = params['status_junk'].to_s
    inv.update_own(row_id, 2, website: true, sold_price: params['sold_price'].to_s)
  when 'status_bullion'
    # get row id for bullion
    row_id = params['status_bullion'].to_s
    inv.update_own(row_id, 3, website: true, sold_price: params['sold_price'].to_s)
  when 'status_cash'
    row_id = params['status_cash'].to_s
    inv.update_cash_own(row_id, params['sold_price'].to_s , website: true)
  when 'status_gold'
    row_id = params['status_gold'].to_s
    inv.update_own(row_id, 5, website: true, sold_price: params['sold_price'].to_s)
  when 'status_dns'
    row_id = params["status_dns"].to_s
    inv.update_own(row_id, 6, website: true, sold_price: params['sold_price'].to_s)
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
  when "delete_cash"
    inv.delete_row(params["delete_cash"], 4)
  when "delete_gold"
    inv.delete_row(params["delete_gold"], 5)
  when "delete_dns"
    inv.delete_row(params["delete_dns"], 6)
	end
	erb :index
end
