# frozen_string_literal: true

require 'sqlite3'
require 'colorize'
class Sql
  def initialize
    @db = SQLite3::Database.new 'test2.db'
  end
  
end

class Bar < Sql
  def test_price
    count = 0
    total = 0
    table = get_option(2)
    @db.execute("select price from #{table};").each do |row|
      row = row.shift
      total += row
      count += 1
    end
    total / count
  end

  

  def avg_price
    count = 0
    total = 0
    @db.execute('select price from Bar;').each do |row|
      row = row.shift
      total += row
      count += 1
    end
    total / count
  end

  def select_bar
  begin
    @db.execute('select * from Bar;').each do |i|
      puts i.join(' | ')
    end
  rescue SQLite3::SQLException
  end

  def select_total
    total = 0
    @db.execute('select total from Bar;').each do |row|
      row = row.shift
      total += row
    end
    total
  end

  def select_total_oz
    total_oz = 0
    @db.execute('select oz from Bar;').each do |row|
      row = row.shift
      total_oz += row
    end
    total_oz
  end

  def select_shipping_total
    total_shipping = 0
    @db.execute('select oz from Bar;').each do |row|
      row = row.shift
      total_shipping += row
    end
    total_shipping
  end
end

class JunkSilver < Sql
  def input
    begin
      
    rescue SQLite3::SQLException
    end
    r = []
    ['Bought Date',
     'Spot Price',
     'Amount',
     'Price',
     'Shipping',
     'Total',
     'OZ',
     'Name',
     'Status',
     'Sold Value',
     'Seller',
     'Method'].each do |t|
      print("Enter #{t}:")
      input = gets.chomp
      r << input
    end
    @db.execute 'insert into Junk values (?,?,?,?,?,?,?,?,?,?,?,?,?)', nil, r[0], r[1], r[2], r[3], r[4], r[5], r[6],
                r[7], r[8], r[9], r[10], r[11]
  end

  def update_own(id)
    @db.execute("select status from Junk where id = '#{id}';").each do |row|
      row = row.shift
      if row.eql?('own')
        @db.execute("UPDATE Junk SET status = 'sold' WHERE id='#{id}';")
      else
        @db.execute("UPDATE Junk SET status = 'own' WHERE id='#{id}';")
      end
      next unless row.eql?('own')

      print('Enter amount sold for: ')
      sold_price = gets.chomp
      if sold_price.match?(/\A[+-]?\d+(\.\d+)?\z/)
        @db.execute("UPDATE Junk SET sold_value = '#{sold_price}' WHERE id='#{id}';")
      end
      print("\n\n\n")
    end
  end

  def delete_entry(id)
    @db.execute("select status from Junk where id = '#{id}';").each do |row|
      puts row.join(' | ')
    end
    print('Are you sure you want to delete this row (y or n )?:')
    delete = gets.chomp
    if delete.eql?('y')
      @db.execute("DELETE FROM Junk WHERE id = '#{id}';")
    elsif delete.eql?('n')
      puts 'Existing...'
    else
      puts 'Input did not match, y or n.'
    end
  end

  def select_shipping_total
    total_shipping = 0
    @db.execute('select oz from Junk;').each do |row|
      row = row.shift
      total_shipping += row
    end
    total_shipping
  end

  def select_total
    total = 0
    @db.execute('select total from Junk;').each do |row|
      row = row.shift
      total += row
    end
    total
  end

  def select_total_oz
    total_oz = 0
    @db.execute('select oz from Junk;').each do |row|
      row = row.shift
      total_oz += row
    end
    total_oz
  end

  def select_junk
    @db.execute('select * from Junk;').each do |i|
      puts i.join(' | ')
    end
  rescue SQLite3::SQLException
  end
end
# js = JunkSilver.new
#
# bar = Bar.new
# bar.input
# total = 0
# bar_total  = bar.select_total
# junk_total = js.select_total
# total += bar_total + junk_total
# puts "#{total}"
# js.update_own(id)

# js.select_total_oz
# js.select_total
# js.delete_entry(1)
# js.select_junk
# menu = "
# 1) Input new Data
# 2) Select Total OZ
# 3) Delete Entry
# 4) Show table
# 5) Update OWN
# "
# map = {
#   "1" => "Selected to input new data\n\n\n\n",
#   "2" => "Total OZ was selected...\n\n\n\n",
#   "3" => "Delete Entry was selected...\n\n\n\n",
#   "4" => "Showing whole table...\n\n\n\n",
#   "5" => "Updating Status...\n\n\n\n"
# }
#
# print(menu)
# print("Enter Input:")
# input = gets.chomp.to_i
# print("\n\n")
#
# if map.has_key?("#{input}")
#   puts map[input.to_s].red
# end
# case input
# when 1
#   js.input
# when 2
#   js.select_total
# when 3
#   print("Enter entry ID:")
#   id = gets.chomp
#   js.delete_entry(id)
# when 4
#   js.select_junk
# when 5
#   print("Enter ID to update own: ")
#   id = gets.chomp
#   js.update_own(id)
#   js.select_junk
# end

module Silver
  def self.total
    js  = JunkSilver.new
    bar = Bar.new
    total = 0
    bar_total  = bar.select_total
    junk_total = js.select_total
    total += bar_total + junk_total
    puts "$#{total}"
  end

  def self.shipping_total
    bar  = Bar.new
    junk = JunkSilver.new
    bar_shipping  = bar.select_shipping_total
    junk_shipping = junk.select_shipping_total
    puts "Bar Shipping: #{bar_shipping}\n"
    puts "Junk Shipping: #{junk_shipping}\n"
  end

  def self.total_oz
    total_oz = 0
    js  = JunkSilver.new
    bar = Bar.new
    junk_oz = js.select_total_oz
    bar_oz  = bar.select_total_oz
    total_oz += junk_oz + bar_oz
    puts "Junk oz:#{junk_oz}\nBar oz:#{bar_oz}\n\n"
    puts "Total OZ:#{total_oz}\n"
  end

  def self.avg_price
    bar = Bar.new
    puts "AVERAGE: #{bar.avg_price}\n"
  end

end
# Silver.avg_price
# Silver.total_oz
# Silver.shipping_total

