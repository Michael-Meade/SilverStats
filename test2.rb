# frozen_string_literal: true
require 'sqlite3'
require 'colorize'
require 'terminal-table'
require 'json'
require 'httparty'
class Sql
  def initialize
    @db = SQLite3::Database.new 'test_db.db'

    #'test2.db'
    #'test_db.db'
    begin
      ["Bar", "Junk", "Bullion"].each do |table|
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
    when 3
      "Bullion"
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
    begin
      count = 0
      total = 0
      table = get_options(id)
      @db.execute("select price from #{table};").each do |row|
        row = row.shift
        total += row
        count += 1
      end
      total / count
    rescue => e
      puts "ERROR: #{e}".red
    end
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
    bar_own       = @db.execute("select status from Bar where status = 'own';").count
    junk_own      = @db.execute("select status from Junk where status = 'own';").count
    bar_sold      = @db.execute("select status from Bar where status = 'sold';").count
    junk_sold     = @db.execute("select status from Junk where status = 'sold';").count
    bullion_own   = @db.execute("select status from Bullion where status = 'own';").count
    bullion_sold  = @db.execute("select status from Bullion where status = 'sold';").count
  return bar_own, junk_own, bar_sold, junk_sold, bullion_own, bullion_sold
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
  def update_own(row_id, id)
    table = get_options(id)
    @db.execute("select status from #{table} where id = '#{row_id}';").each do |row|
      row = row.shift
      if row.eql?('own')
        @db.execute("UPDATE #{table} SET status = 'sold' WHERE id='#{row_id}';")
      else
        @db.execute("UPDATE #{table} SET status = 'own' WHERE id='#{row_id}';")
      end
      #next unless row.eql?('own')

      print('Enter amount sold for: ')
      sold_price = gets.chomp
      if sold_price.match?(/\A[+-]?\d+(\.\d+)?\z/)
        @db.execute("UPDATE #{table} SET sold_value = '#{sold_price}' WHERE id='#{row_id}';")
      end
      print("\n\n\n")
    end
  end
end
module Silver
  @silver = Inventory.new
  def self.get_silver_price(amount)
    r = HTTParty.get("https://duckduckgo.com/js/spice/currency/#{amount}/xag/usd")
    r_clean  = r.gsub('ddg_spice_currency(', '').gsub(');', '').strip
    json = JSON.parse(r_clean)["to"].shift
    return json["mid"]
  end
  def self.print_table(rows, headers=nil, title=nil)
    t = Terminal::Table.new :headings => headers, :title => title
    t.rows  =  rows
    t.style = {:all_separators => true}
    t.style = {border: :unicode}
    puts t.render.green
  end
  def self.total_oz
    bar     = @silver.select_total_oz(1)
    junk    = @silver.select_total_oz(2)
    bullion = @silver.select_total_oz(3) 
    bar_amount     = get_silver_price(bar)
    junk_amount    = get_silver_price(junk)
    bullion_amount = get_silver_price(bullion) 
    total          = bar + junk + bullion
    amount_all     = bar_amount + junk_amount + bullion_amount
    rows = [["Bar Total OZ", bar, "$#{bar_amount}"], ["Junk Total OZ", junk, "$#{junk_amount}"], ["Bullion Total OZ", bullion, "$#{bullion_amount}"], ["Total OZ", total, "$#{amount_all}" ]]
    print_table(rows)
  end
  def self.select_bar
    @silver.select(1)
  end
  def self.select_junk
    @silver.select(2)
  end
  def self.select_bullion
    @silver.select(3)
  end
  def self.price_avg
    bar     = @silver.select_price_avg(1)
    junk    = @silver.select_price_avg(2)
    bullion = @silver.select_price_avg(3)
    rows = [["Bar Price AVG", bar], ["Junk Price AVG", junk], ["Bullion Price AVG", bullion]]
    print_table(rows)
  end
  def self.franklins
    count = @silver.select_franklins.count
    rows  = [["Franklin Half Count", count]]
    print_table(rows)
  end
  def self.method_of_purchase
    rows = @silver.select_method(1)
    print_table(rows, ["Site", "Count"], "Bar Silver")
    rows = @silver.select_method(2)
    print_table(rows, ["Site", "Count"], "Junk Silver")
    rows = @silver.select_method(3)
    print_table(rows, ["Site", "Count"], "Bullion Silver")
  end
  def self.display_all
    bar_price_avg     = @silver.select_price_avg(1)
    junk_price_avg    = @silver.select_price_avg(2)
    bullion_price_avg = @silver.select_price_avg(3) 
    rows = [["Bar Price AVG", bar_price_avg],
            ["Junk Price AVG", junk_price_avg],
            ["Bullion Price AVG", bullion_price_avg]]
    print_table(rows)
    print("\n\n")
    bar_total_oz     = @silver.select_total_oz(1)
    junk_total_oz    = @silver.select_total_oz(2)
    bullion_total_oz = @silver.select_total_oz(3)
    bar_amt          = get_silver_price(bar_total_oz) 
    junk_amt         = get_silver_price(junk_total_oz)
    bullion_amt      = get_silver_price(bullion_total_oz)
    total_oz         = junk_total_oz + bar_total_oz + bullion_total_oz
    rows = [["Junk OZ Total", junk_total_oz, "$#{junk_amt}"],
            ["Bar OZ Total", bar_total_oz, "$#{bar_amt}"],
            ["Bullion OZ Total", bullion_total_oz, "$#{bullion_amt}"],
            ["Total OZ", "$#{total_oz}", "#{get_silver_price(total_oz)}"]]
    print_table(rows)
    print("\n\n")
    bar_shipping_total     = @silver.shipping_total(1)
    junk_shipping_total    = @silver.shipping_total(2)
    bullion_shipping_total = @silver.shipping_total(3)
    total = bar_shipping_total + junk_shipping_total + bullion_shipping_total
    rows = [["Bar Shipping Total", bar_shipping_total],
            ["Junk Shipping Total", junk_shipping_total],
            ["Bullion Shipping Total", bullion_shipping_total],
            ["Shipping Total", total ]]
    print_table(rows)
    print("\n\n")
    results = @silver.sold_own
    #bar_own, junk_own, bar_sold, junk_sold, bullion_own, bullion_sold
    rows = [["Bar Own Count", results[0]],
            ["Junk Own Count", results[1]],
            ["Bar Sold Count", results[2]],
            ["Junk Sold Count", results[3]],
            ["Bullion Own Count", results[4]],
            ["Bullion Sold Count", results[5]]]
    print_table(rows)
    print("\n\n")
    rows = @silver.select_method(1)
    print_table(rows, ["Site", "Count"], "Bar Silver")
    rows = @silver.select_method(2)
    print_table(rows, ["Site", "Count"], "Junk Silver")
    rows = @silver.select_method(3)
    print_table(rows, ["Site", "Count"], "Bullion Silver")
  end
  def self.sold_vs_own
    results = @silver.sold_own
    rows = [["Bar Own Count", results[0]],
            ["Junk Own Count", results[1]],
            ["Bar Sold Count", results[2]],
            ["Junk Sold Count", results[3]],
            ["Bullion Own Count", results[4]],
            ["Bullion Sold Count", results[5]]]
    print_table(rows)
  end
  def self.enter_bar
    @silver.input(1)
  end
  def self.enter_junk
    @silver.input(2)
  end
  def self.change_own_status(row_id, id)
    @silver.update_own(row_id, id)
  end
  def self.enter_bullion
    @silver.input(3)
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
    [10, "Enter New Junk"],
    [11, "Update Bar Own Status"],
    [12, "Update Junk Own Status"],
    [13, "Enter New Bullion"],
    [14, "Select Bullion"],
    [15, "Update Bullion Own"],
    [16, "Quit"]]
    print_table(rows)
  end
end
while true
  print("\n\n\n\n")
  Silver.menu
  print("Enter choice:")
  choice = gets.chomp
  print("\n\n\n")
  case choice.to_i
  when 1
    Silver.select_junk
    sleep 10
  when 2
    Silver.select_bar
    sleep 10
  when 3
    Silver.total_oz
    sleep 10
  when 4
    Silver.price_avg
    sleep 10
  when 5
    Silver.display_all
    sleep 10
  when 6
    Silver.sold_vs_own
    sleep 10
  when 7
    Silver.enter_bar
  when 8
    Silver.franklins
    sleep 10
  when 9
    Silver.method_of_purchase
    sleep 10
  when 10
    Silver.enter_junk
    sleep 10
  when 11
    print("Enter Row ID:")
    row_id = gets.chomp
    Silver.change_own_status(row_id, 1)
  when 12
    print("Enter Row ID:")
    row_id = gets.chomp
    Silver.change_own_status(row_id, 2)
  when 13
    # Enter Bullion
    Silver.enter_bullion
    sleep 10
  when 14
    # Select Bullion
    Silver.select_bullion
    sleep 10
  when 15
    # Update Own Bullion
    print("Enter Row ID: ")
    row_id = gets.chomp
    Silver.change_own_status(row_id, 3)
  when 16
    exit
  end
end