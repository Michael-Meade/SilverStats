# frozen_string_literal: true
require 'sqlite3'
require 'colorize'
require 'terminal-table'
require 'json'
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
  def sold_own
    bar_own   = @db.execute("select status from Bar where status = 'own';").count
    junk_own  = @db.execute("select status from Junk where status = 'own';").count
    bar_sold  = @db.execute("select status from Bar where status = 'sold';").count
    junk_sold = @db.execute("select status from Junk where status = 'sold';").count
  return bar_own, junk_own, bar_sold, junk_sold
  end
  def select_franklins
    @db.execute("select name from Junk where name like '%franklin%';")
  end
  def select_method(id)
    table = get_options(id)
    meth = {}
    @db.execute("select method from #{table};").each do |row|
      if !meth.has_key?(row[0])
        name = row[0]
        meth[name] = 1
      else
        meth[row[0]] += 1
      end
    end
    methods_array = []
    meth.each do |k,v|
      methods_array << [k,v]
    end
  methods_array
  end 
end
module Silver
  @silver = Inventory.new
  def self.print_table(rows, headers=nil, title=nil)
    t = Terminal::Table.new :headings => headers, :title => title
    t.rows  =  rows
    t.style = {:all_separators => true}
    t.style = {border: :unicode}
    puts t.render.green
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
  def self.franklins
    count = @silver.select_franklins.count
    rows  = [["Franklin Half Count", count]]
    print_table(rows).green
  end
  def self.test
    bar  =  @silver.select_price_avg(1)
    junk = @silver.select_price_avg(2)
    count = @silver.select_franklins.count
    rows  = [["Franklin Half Count", count]]
    rows2 = [["Bar Price AVG", bar], ["Junk Price AVG", junk]]
    t = rows << [[rows2]]
    print_table(t)
  end
  def self.method_of_purchase
    rows = @silver.select_method(1)
    print_table(rows, ["Site", "Count"], "Bar Silver")
    rows = @silver.select_method(2)
    print_table(rows, ["Site", "Count"], "Junk Silver")
  end
  def self.display_all
    bar_price_avg  = @silver.select_price_avg(1)
    junk_price_avg = @silver.select_price_avg(2)
    bar_total_oz   = @silver.select_total_oz(1)
    junk_total_oz  = @silver.select_total_oz(2)
    rows = [["Bar Price AVG", bar_price_avg], ["Junk Price AVG", junk_price_avg]]
    print_table(rows)
    print("\n\n")
    rows = [["Junk OZ Total", junk_total_oz],
            ["Bar OZ Total", bar_total_oz],
            ["Total OZ", junk_total_oz + bar_total_oz]]
    print_table(rows)
    print("\n\n")
    bar_shipping_total  = @silver.shipping_total(1)
    junk_shipping_total = @silver.shipping_total(2)
    total = bar_shipping_total + junk_shipping_total
    rows = [["Bar Shipping Total", bar_shipping_total],
            ["Junk Shipping", junk_shipping_total],
            ["Shipping Total", total ]]
    print_table(rows)
    print("\n\n")
    results = @silver.sold_own
    rows = [["Bar Own Count", results[0]],
            ["Junk Own Count", results[1]],
            ["Bar Sold Count", results[2]],
            ["Junk Sold Count", results[3]]]
    print_table(rows)
    print("\n\n")
    rows = @silver.select_method(1)
    print_table(rows, ["Site", "Count"], "Bar Silver")
    rows = @silver.select_method(2)
    print_table(rows, ["Site", "Count"], "Junk Silver")
  end
  def self.sold_vs_own
    results = @silver.sold_own
    rows = [["Bar Own Count", results[0]],
            ["Junk Own Count", results[1]],
            ["Bar Sold Count", results[2]],
            ["Junk Sold Count", results[3]]]
    print_table(rows)
  end
  def self.menu
    rows = [[1, "Select Junk"],
    [2, "Select Bar"],
    [3, "Select All Total OZ"],
    [4, "Price AVG"],
    [5, "Display All Info"],
    [6, "Sold & Own Info"],
    [7, "Enter New Bars"],
    [8, "Find Franklins"],
    [9, "Select Method of Purchase"],
    [10, "Quit"]]
    print_table(rows)
  end
end
#s = Silver.new
#Silver.total_oz-
#puts s.select_total_oz(1)
while true
=begin
  menu = "
  1) Select Junk
  2) Select Bar
  3) Select Total OZ ( Bar & Junk )
  4) Price Average
  5) Display All Information
  6) Sold and Own Data
  7) Enter New Bars
  8) Find Franklins
  9) Select Method of purchase
  10) Test
  10) Quit
  \n"
=end
  print("\n\n\n\n")
  Silver.menu
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
  when 6
    Silver.sold_vs_own
  when 7
  when 8
    Silver.franklins
  when 9
    Silver.method_of_purchase
  when 10
    Silver.test
  when 11
    exit
  end
end