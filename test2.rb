# frozen_string_literal: true
require 'sqlite3'
require 'colorize'
require 'terminal-table'
class Sql
  def initialize
    @db = SQLite3::Database.new 'test2.db'
    begin
      ["Bar", "Junk"].each do |table|
        @db.execute("create table IF NOT EXISTS #{table} (id integer primary key autoincrement, bought_date text,
            spot_price INTEGER,
            amount INTEGER,
            price real,
            shipping real,
            total real,
            oz INTEGER,
            name text,
            status text,
            sold_value INTEGER,
            seller text,
            method text);")
      end
    rescue SQLite3::SQLException => e
      puts "#{e}"
    end
  end
end
class Inventory < Sql
  def get_options(id)
    case id.to_i
    when 1
      "Bar"
    when 2
      "Junk"
    end
  end
  def input(id)
    table_name = get_options(id)
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
    @db.execute "insert into #{table_name} values (?,?,?,?,?,?,?,?,?,?,?,?,?)", nil, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7],
                r[8], r[9], r[10], r[11]
  end
  def select_price_avg(id)
    count = 0
    total = 0
    table = get_options(id)
    @db.execute("select price from #{table};").each do |row|
      row = row.shift
      total += row
      count += 1
    end
    total / count
  end
  def select(id)
    table = get_options(id)
    begin
      @db.execute("select * from #{table} ;").each do |i|
        puts i.join(' | ')
      end
    rescue SQLite3::SQLException
    end
  end
  def shipping_total(id)
    table = get_options(id)
    total_shipping = 0
    @db.execute("select shipping from #{table};").each do |row|
      row = row.shift
      total_shipping += row
    end
    total_shipping
  end
  def select_total_oz(id)
    table = get_options(id)
    total_oz = 0
    @db.execute("select oz from #{table};").each do |row|
      row = row.shift
      total_oz += row
    end
    total_oz
  end

end
module Silver
  @silver = Inventory.new
  def self.print_table(rows)
    t = Terminal::Table.new
    t.rows  =  rows
    t.style = {:all_separators => true}
    t.style = {border: :unicode}
    puts t.render
  end
  def self.total_oz
    bar    = @silver.select_total_oz(1)
    junk   = @silver.select_total_oz(2)
    rows = [["Bar Total", bar], ["Junk Total", junk], ["Total", bar + junk]]
    print_table(rows)
  end
  def self.select_bar
    @silver.select(1)
  end
  def self.select_junk
    @silver.select(2)
  end
  def self.price_avg
      bar  =  @silver.select_price_avg(1)
      junk = @silver.select_price_avg(2)
      rows = [["Bar Price AVG", bar], ["Junk Price AVG", junk]]
      print_table(rows)
  end
  
  def self.display_all
    bar_price_avg  = @silver.select_price_avg(1)
    junk_price_avg = @silver.select_price_avg(2)
    bar_total_oz   = @silver.select_total_oz(1)
    junk_total_oz  = @silver.select_total_oz(2)
    rows = [["Bar Price AVG", bar_price_avg], ["Junk Price AVG", junk_price_avg]]
    print_table(rows)
    print("\n\n")
    rows = [["Junk OZ Total", junk_total_oz], ["Bar OZ Total", bar_total_oz], ["Total OZ", junk_total_oz + bar_total_oz]]
    print_table(rows)
    print("\n\n")
    bar_shipping_total  = @silver.shipping_total(1)
    junk_shipping_total = @silver.shipping_total(2)
    total = bar_shipping_total + junk_shipping_total
    rows = [["Bar Shipping Total", bar_shipping_total],
            ["Junk Shipping", junk_shipping_total],
            ["Shipping Total", total ]]
    print_table(rows)
  end
end
#s = Silver.new
#Silver.total_oz-
#puts s.select_total_oz(1)
while true
  menu = "
  1) Select Junk
  2) Select Bar
  3) Select Total OZ ( Bar & Junk )
  4) Price Average
  5) Display All Information
  \n"
  print(menu)
  print("Enter choice:")
  choice = gets.chomp
  print("\n\n\n")
  case choice.to_i
  when 1
    Silver.select_junk
  when 2
    Silver.select_bar
  when 3
    Silver.total_oz
  when 4
    Silver.price_avg
  when 5
    Silver.display_all
  when 9
    exit
  end
end