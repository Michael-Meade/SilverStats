# frozen_string_literal: true
### out dated as of 1/27/2026
require 'sqlite3'
require 'colorize'
require 'terminal-table'
require 'json'
require 'httparty'
require 'logger'
require 'date'
class Sql
  def initialize
    @db = SQLite3::Database.new 'test2.db'
    #'test_db.db' 
    #'test2.db'
    begin
      @db.execute('create table IF NOT EXISTS Cash (id integer primary key autoincrement, amount integer, recipient text, status text, spent_amount integer);')
    rescue StandardError => e
      puts "ERROR: #{e}".red
      Logger.error("Error with creating Cash table: #{e}")
    end
    begin
      %w[Bar Junk Bullion Gold DNS].each do |table|
        @db.execute("create table IF NOT EXISTS #{table} (id integer primary key, bought_date text,
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
      puts e
      Logger.error("Error with creating table: #{e}")
    end
  end
end

class Inventory < Sql
  Logger = Logger.new('logs.txt')
  def get_options(id)
    case id.to_i
    when 1
      'Bar'
    when 2
      'Junk'
    when 3
      'Bullion'
    when 4
      'Cash'
    when 5
      'Gold'
    when 6
      # Do Not Sell
      'DNS'
    end
  end

  def input_site(id, params)
    r = params
    table_name = get_options(id)
    uuid = SecureRandom.random_number(99999999)
    # if equals junk
    if id.eql?(2)
      begin 
        new_oz = r['oz'].to_f * r["amount"].to_f

      rescue => e
        Logger.info("ERROR IN Junk Silver adding amount to oz.")
        new_oz = r['oz']
      end
        data = uuid, r['bought_date'], r['spot_price'], r['amount'], r['price'], r['shipping'],
        r['total'], new_oz, r['name'], r['status'], r['sold_value'], r['seller'], r['method']


        @db.execute "insert into #{table_name} values (?,?,?,?,?,?,?,?,?,?,?,?,?)", data
        
        Logger.info("INSERT INTO JUNK: #{data}.")
    else
      # All the other types get passed here.
      data = uuid, r['bought_date'], r['spot_price'], r['amount'], r['price'],
             r['shipping'], r['total'], r['oz'], r['name'], r['status'], r['sold_value'],
             r['seller'], r['method']

      @db.execute "insert into #{table_name} values (?,?,?,?,?,?,?,?,?,?,?,?,?)", data
        
      Logger.info("INSERT INTO JUNK: #{data}.")
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
      if t.to_s.eql?('Status')
        # quality control for the input to make sure the row is uniformed
        menu = "1) Own\n2) Sold\n"
        print(menu)
        print("Enter #{t}:")
        input = gets.chomp
        case input.to_i
        when 1
          r << 'own'
        when 2
          r << 'sold'
        end
      elsif t.to_s.eql?('Bought Date')
        action = true
        # keeps asking for the date until they give correct format.
        while action == true
          print('Enter date: ')
          date = gets.chomp
          # Make sure that the input is a date with: month/day/year
          next unless date.match?(%r{\A\d{2}/\d{2}/\d{4}\Z})

          r << date
          # stops the endless loop since we got the correct format
          action = false
        end
      elsif t.to_s.eql?('Method')
        # quality control the Method Input
        method_menu = "1) Reddit\n2) JMbullion\n3) APMEX\n4) Gift\n5) Unknown\n6) Ebay\n7) Other option"
        print(method_menu)
        print("\n\n\nEnter Method: ")
        method_input = gets.chomp
        Logger.info("Entered method, #{method_input}")
        case method_input.to_i
        when 1
          r << 'Reddit'
        when 2
          r << 'JMbullion'
        when 3
          r << 'APMEX'
        when 4
          r << 'Gift'
        when 5
          r << 'Unknown'
        when 6
          r << 'Ebay'
        when 7
          print('Enter other option: ')
          op = gets.chomp
          r << op
          print("\n\n")
        end
        puts "\n\n\n"
      elsif t.eql?('OZ')
        oz_menu  = "\n\n\n1) 1 oz\n2) 0.3617 oz (Franklin Half Dollar)\n3) 2 oz\n4) 0.07234 oz (Mercury dimes)"
        oz_menu2 = "\n5) 0.36169 oz (walkers)\n6) 0.77344 oz (peace dollar)\n7) 0.18084 oz (Washington Quarter)"
        oz_menu3 = "\n8) 0.3161 oz (Eisenhower dollar)\n9) 0.1479 oz (Kennedy Half Dollars)"
        oz_menu4 = "\n10) 0.05626 oz (Jefferson nickel)\n11) 0.5 oz\n12) Other\n\n"
        print(oz_menu + oz_menu2 + oz_menu3 + oz_menu4)
        print("\n\n")
        print('Enter OZ amount: ')
        oz_input = gets.chomp
        case oz_input.to_i
        when 1
          r << '1'
          Logger.info('Entered 1 oz')
        when 2
          r << '0.3617'
          Logger.info('Entered 0.3617 oz')
        when 3
          r << '2'
          Logger.info('Entered 2 oz')
        when 4
          r << '0.07234'
          Logger.info('Entered 0.07234 oz')
        when 5
          r << '0.36169'
          Logger.info('Entered 0.36169 oz')
        when 6
          r << '0.77344'
          Logger.info('Entered 0.77344 oz')
        when 7
          r << '0.18084'
          Logger.info('Entered 0.18084 oz')
        when 8
          r << '0.3161'
          Logger.info('Entered 0.3161 oz')
        when 9
          r << '0.1479'
          Logger.info('Entered 0.1479 oz')
        when 10
          r << '0.05626'
          Logger.info('Entered 0.05626 oz')
        when 11
          r << '0.5'
          Logger.info('Entered 0.5 oz')
        when 12
          print('Enter OZ amount: ')
          amount = gets.chomp
          r << amount
          Logger.info("Entered #{amount}")
        end
      else
        print("Enter #{t}:")
        input = gets.chomp
        r << input
      end
    end
    @db.execute "insert into #{table_name} values (?,?,?,?,?,?,?,?,?,?,?,?,?)", nil, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7],
                r[8], r[9], r[10], r[11]
    Logger.info("Insert into table #{table_name} -\n\n\n bought_date: #{r[0]} \n spot price: #{r[1]} \n Amount: #{r[2]} \n Price: #{r[3]} \n Shipping: #{r[4]} \n Total: #{r[5]} \n OZ: #{r[6]} \n Name: #{r[7]} \n Status: #{r[8]} \n Sold value: #{r[9]} \n Seller: #{r[10]} \n Method: #{r[11]}")
  end

  def input_cash(data, html: false)
    if html.eql?(false)
      print('Enter amount of Cash: ')
      cash_amount = gets.chomp
      print('Enter from who: ')
      from = gets.chomp
      @db.execute 'insert into Cash values (?, ?, ?, ?, ?)', nil, cash_amount, from, 'own', 0
      Logger.info("Entered #{cash_amount} from #{from}")
    else
      cash_amount    = data["cash_amount"]
      from           = data["cash_from"]
      current_amount = data["cash_current"]
      @db.execute 'insert into Cash values (?, ?, ?, ?, ?)', nil, cash_amount, from, 'own', current_amount
      Logger.info("Entered #{cash_amount} from #{from}")
    end
  end
  def spot_avg(id)
    table     = get_options(id)
    avg_total = 0
    count     = 0
    avg_total = avg_total.dup
    @db.execute("select spot_price from #{table};").each do |row|
      row = row.dup
      row = row.shift
      avg_total += row.to_i
      count += 1
    end
    begin
      if avg_total.to_i.eql?(0)
        return [ 0, count]
      else
        avg = avg_total / count
        return [ avg, count ]
      end
    rescue => e
      puts "#{e}"
    end
  
  end
  def select_price_avg(id, html_table: false)
    count = 0
    total = 0
    table = get_options(id) # Get the type of silver
    @db.execute("select price from #{table};").each do |row|
      row = row.shift
      total += row
      count += 1
    end
    total / count # get the average
  rescue StandardError => e
    puts "ERROR: #{e}".red
    Logger.error("Error: #{e} \n table: #{table}")
  end

  def select(id, html_table: false)
    table = get_options(id) # Get the type of silver
    if !html_table
      begin
        @db.execute("select * from #{table} ;").each do |i|
          puts i.join(' | ')
        end
      rescue SQLite3::SQLException => e
        puts "ERROR: #{e}".red
        Logger.error("Error with selecting table: #{table}")
        Logger.error("error: #{e}")
      end
    else
      html_out = []
      @db.execute("select * from #{table} ;").each do |i|
        html_out << i
      end
      html_out
    end
  end

  def shipping_avg(id)
    total_shipping = 0
    count = 0
    table = get_options(id) # Get the type of silver.
    @db.execute("select shipping from #{table};").each do |row|
      row = row.dup
      row = row.shift
      total_shipping += row
      count += 1
    end
    begin
      if count.to_i.eql?(0)
        Logger.info("Shipping avg #{table}: 0")
        return [0, count]
      end
      if total_shipping.to_i.eql?(0)
        Logger.info("total_shipping -> #{table}:   0")
        return [0, count]
      end
      if !count.to_i.eql?(0) && !total_shipping.to_i.eql?(0)
        Logger.info("Shipping avg #{table}: #{total_shipping / count}")
        [total_shipping / count, count]
      end
    rescue StandardError => e
      puts "ERROR: #{e}".red
      Logger.error("Error: #{e} \n table: #{table}")
    end
  end

  def shipping_total(id)
    table = get_options(id) # Get the type of silver
    total_shipping = 0
    @db.execute("select shipping from #{table};").each do |row|
      row = row.dup
      row = row.shift
      total_shipping += row
    end
    Logger.info("Shipping total #{table}: #{total_shipping}")
    total_shipping
  end
  
  def list_sellers
    total = []
    # JM
    jm_total = 0
    @db.execute("select total from Bullion where seller = 'JMbullion';").each { |amount| jm_total = jm_total.dup; jm_total += amount.shift }
    @db.execute("select total from Bar where seller = 'JMbullion';").each { |amount| jm_total = jm_total.dup; jm_total += amount.shift }
    @db.execute("select total from Junk where seller = 'JMbullion';").each { |amount| jm_total = jm_total.dup; jm_total += amount.shift }
    total << ["JMbullion", jm_total]

    # Golden State Mint
    gsm_total = 0

    @db.execute("select total from Bullion where seller = 'Golden State Mint';").each { |amount| gsm_total = gsm_total.dup; gsm_total += amount.shift }
    @db.execute("select total from Bar where seller = 'Golden State Mint';").each { |amount| gsm_total = gsm_total.dup; gsm_total += amount.shift }
    @db.execute("select total from Junk where seller = 'Golden State Mint';").each { |amount| gsm_total = gsm_total.dup; gsm_total += amount.shift }
    total << ["Gold State Mint", gsm_total ]

    # MoneyMetals
    mm_total = 0

    @db.execute("select total from Bullion where seller = 'MoneyMetals';").each { |amount| mm_total = mm_total.dup; mm_total += amount.shift }
    @db.execute("select total from Bar where seller = 'MoneyMetals';").each { |amount| mm_total = mm_total.dup; mm_total += amount.shift }
    @db.execute("select total from Junk where seller = 'MoneyMetals';").each { |amount| mm_total = mm_total.dup; mm_total += amount.shift }
    total << ["MoneyMetals", mm_total]

    # APMEX
    a_total = 0

    @db.execute("select total from Bullion where seller = 'APMEX';").each { |amount| a_total = a_total.dup; a_total += amount.shift }
    @db.execute("select total from Bar where seller = 'APMEX';").each { |amount| a_total = a_total.dup; a_total += amount.shift }
    @db.execute("select total from Junk where seller = 'APMEX';").each { |amount| a_total = a_total.dup;a_total += amount.shift }
    @db.execute("select total from Gold where seller = 'APMEX';").each { |amount| a_total = a_total.dup; a_total += amount.shift }
    total << ["APMEX", a_total]

  Logger.info("List sites: #{total}")
  total
  end

  def list_years
    years_hash = {}
    ids = [1,2,3]
    ids.each do |id|
      table = get_options(id)
      @db.execute("select bought_date from #{table};").each do |date|
        date = date.dup
        date = date.shift
        year = Date.parse(date).year
        unless years_hash.has_key?(year)
            years_hash[year] = 1
        else
          years_hash[year] += 1
        end
      end
    end
  years_hash
  end
  def list_months
    months_hash = {}
    ids = [1,2,3]
    ids.each do |id|
      table = get_options(id)
      @db.execute("select bought_date from #{table};").each do |date|
        date = date.dup
        date = date.shift
        month = Date.parse(date).month
        unless months_hash.has_key?(month)
            months_hash[month] = 1
        else
          months_hash[month] += 1
        end
      end
    end
  months_hash
  end
  def select_total_oz(id)
    table = get_options(id) # Get the type of silver
    total_oz = 0

    @db.execute("select oz from #{table} where status = 'own';").each do |row|
      row = row.dup
      row = row.shift
      total_oz += row
    end
    Logger.info("Total oz #{table}: #{total_oz}")
    total_oz
  end

  def sold_own
    # These just get the count of the status of the piece of silvers
    bar_own       = @db.execute("select status from Bar where status = 'own';").count
    junk_own      = @db.execute("select status from Junk where status = 'own';").count
    bar_sold      = @db.execute("select status from Bar where status = 'sold';").count
    junk_sold     = @db.execute("select status from Junk where status = 'sold';").count
    bullion_own   = @db.execute("select status from Bullion where status = 'own';").count
    bullion_sold  = @db.execute("select status from Bullion where status = 'sold';").count
    gold_own      = @db.execute("select status from Gold where status = 'own';").count
    gold_sold     = @db.execute("select status from Gold where status = 'sold';").count
    #  0         1        2          3             4            5           6         7
    [bar_own, junk_own, bar_sold, junk_sold, bullion_own, bullion_sold, gold_own, gold_sold]
  end

  def select_franklins
    # Find and list all of the records that include franklin half dollars in the junk table
    @db.execute("select amount from Junk where name like '%franklin%' AND status = 'own';")
  end

  def select_method(id, html_table: false)
    # get table by id ( junk, bullion, bars )
    table = get_options(id)
    meth = {}
    @db.execute("select method from #{table};").each do |row|
      row = row.dup
      # Checks to see if meth variable has the key
      unless meth.key?(row[0])
        name = row[0]
        # gives the method the value of 1
        meth[name] = 1
      else
        # increase the method count value
        meth[row[0]] += 1
      end
    end
    methods_array = []
    meth.each do |k, v|
      methods_array << [k, v]
    end
    methods_array
  end

  def update_own(row_id, id, website: false, sold_price: 0)
    # gets type of silver via id
    table = get_options(id)
    @db.execute("select status from #{table} where id = '#{row_id}';").each do |row|
      row = row.dup
      row = row.shift
      if row.eql?('own')
        # if own then changes it to sold
        @db.execute("UPDATE #{table} SET status = 'sold' WHERE id='#{row_id}';")
        Logger.info("Updated #{table} changed row: #{row_id} status to sold")
      else
        # if 'sold' then it changes it to own
        @db.execute("UPDATE #{table} SET status = 'own' WHERE id='#{row_id}';")
        Logger.info("Updated #{table} changed row: #{row_id} status to own")
      end
      # next unless row.eql?('own')
      # make sure if the id is less than or equal to 3
      # and the website variable should be equal to false.
      # which by default it is set to.
      if id.to_i <= 3 && website.eql?(false)
        print('Enter amount sold for: ')
        sold_price = gets.chomp
        # make sure input is a number.
        if sold_price.match?(/\A[+-]?\d+(\.\d+)?\z/)
          @db.execute("UPDATE #{table} SET sold_value = '#{sold_price}' WHERE id='#{row_id}';")
          Logger.info("Updated #{table} changed row: #{row_id} with #{sold_price}")
        end
      # if the website variable is set to true it will not
      # print the text to be updated, it will use the sold_price variable
      elsif website.eql?(true)
        if sold_price.match?(/\A[+-]?\d+(\.\d+)?\z/)
          @db.execute("UPDATE #{table} SET sold_value = '#{sold_price}' WHERE id='#{row_id}';")
          Logger.info("Updated #{table} changed row: #{row_id} with #{sold_price}")
        end
        print("\n\n\n")
      end
    end
  end

  def update_cash_own(row_id, spent_amount, website: false)
    # The row should only have the status as 'own' or 'sold'
    # Depending what status it will do the oppsite of the value.
    # For example if sold it will change to own, if own it will change to sold
    @db.execute("select status from Cash where id = '#{row_id}';").each do |row|
      row = row.shift
      row = row.dup
      if row.eql?('own')
        # Changes own to spent
        @db.execute("UPDATE Cash SET status = 'spent' WHERE id='#{row_id}';")
        Logger.info("Cash Table: Changed from 'own' to 'spent' on row: #{row_id}")
      else
        # changes spent to own
        @db.execute("UPDATE Cash SET status = 'own' WHERE id='#{row_id}';")
        Logger.info("Cash Table: Changed from 'spent' to 'own' on row: #{row_id}")
      end
      if website.eql?(false)
        print('Enter Spent Amount: ')
        # Update the spent amount
        spent_amount = gets.chomp
        @db.execute("UPDATE Cash SET spent_amount = '#{spent_amount}' WHERE id='#{row_id}';")
        Logger.info("Updated cash table. Updated 'spent_amount' with #{spent_amount} with row_id: #{row_id}")
      else
        @db.execute("select spent_amount from Cash where id = '#{row_id}';").each do |row|
          row = row.shift
          @current_amount = row
        end
        if spent_amount.to_f <= @current_amount.to_f
          new_amount = @current_amount.to_f - spent_amount.to_f
          @db.execute("UPDATE Cash SET spent_amount = '#{new_amount}' WHERE id='#{row_id}';")
          Logger.info("Updated cash table. Updated 'spent_amount' with #{new_amount} with row_id: #{row_id}")
        end
      end
    end
  end

  def sold_total(id)
    # Get the total amount of sold value. This
    # can be done with any table ( junk, bullion, bars, etc)
    table = get_options(id) # get the type of silver
    total = 0
    @db.execute("select sold_value from #{table} where status='sold';").each do |sold|
      sold = sold.dup
      # removes [] from the sold variable
      sold = sold.shift
      total += sold.to_i
    end
    total
  end

  def sold_oz_total(id)
    # Get the total amount of oz sold
    # gets the type of silver
    table    = get_options(id)
    total_oz = 0 # used to total the total oz
    @db.execute("select OZ from #{table} where status='sold'").each do |oz|
      oz = oz.dup
      oz = oz.shift
      total_oz += oz.to_i
    end
    Logger.info("Getting sold OZ total from the table #{table} --> #{total_oz} oz")
    total_oz
  end

  def delete_row(row_id, id)
    row_id = row_id.split(',')
    # Get the type of silver
    table = get_options(id)
    Logger.info("Deleting the row with row_id: #{row_id} on the #{table} table")
    begin
      unless row_id.count.to_i.eql?(1)
        #check if `row_id` element count is not 1
        row_id.each do |id|
          @db.execute("delete from #{table} where id ='#{id}';")
          Logger.info("Deleted row, #{row_id} from the #{table} table.")
        end
      else
        # the row_id count is 1
        row_id = row_id.shift
        # removes the array^
        # Deletes the row by the given 'row_id'
        @db.execute("delete from #{table} where id ='#{row_id}';")
        Logger.info("Deleted row, #{row_id} from the #{table} table.")
      end
    rescue StandardError => e
      # prints the error in red
      puts "ERROR: #{e}".red
      Logger.error("Error with deleting the row with row_id: #{row_id} on the #{table} table")
    end
  end

end

module Silver
  @silver = Inventory.new
  def self.get_silver_price(amount)
    begin
      ua = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.3'
      # use Duck Duck go to get the current price of silver. It will take the
      # amount of silver and use this api to get the current worth of the silver.
      r = HTTParty.get("https://duckduckgo.com/js/spice/currency/#{amount}/xag/usd",
                       { headers: { 'User-Agent' => ua } }).body
      
        r_clean = r.gsub('ddg_spice_currency(', '').gsub(');', '').strip
        if !r_clean.nil?
          json = JSON.parse(r_clean)['to'].shift
          json['mid']
        end
    rescue => e
      puts "#{e}".red
    end
  end

  def self.get_gold_price(amount, gram: true)
    begin
      ua = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.3'
      # use Duck Duck go to get the current price of gold. It will take the
      # amount of gold and use this api to get the current worth of the gold.
      if gram
       amount = amount.to_f / 28.34952
      end
      r = HTTParty.get("https://duckduckgo.com/js/spice/currency/#{amount}/xau/usd",
                       { headers: { 'User-Agent' => ua } }).body
      
        r_clean = r.gsub('ddg_spice_currency(', '').gsub(');', '').strip
        json = JSON.parse(r_clean)['to'].shift
        json['mid']
    rescue => e
      puts "#{e}".red
    end
  end

  def self.print_table(rows, headers = nil, title = nil)
    # used to nicely print the information in a table.
    t = Terminal::Table.new headings: headers, title: title
    t.rows = rows
    t.style = { all_separators: true }
    t.style = { border: :unicode }
    puts t.render.green # print the table in green
  end

  def self.save_total_oz
    bar     = @silver.select_total_oz(1) # 1: Bar
    junk    = @silver.select_total_oz(2) # 2: Junk
    bullion = @silver.select_total_oz(3) # 3: Bullion
    bar_amount     = get_silver_price(bar)     # Add amount of bars to the current price of Silver
    junk_amount    = get_silver_price(junk)    # Add amount of Junk to the current price of Silver
    bullion_amount = get_silver_price(bullion) # Add amount of Bullion to the current price of Silver
    amount_all = bar_amount + junk_amount + bullion_amount # add bar, junk and bullion total together ( $USD )
    time = Time.new
    date = time.strftime('%m/%d/%Y')
    puts "Amount: $#{amount_all}"
    File.open('silver_total.txt', 'a') { |file| file.write("#{date} #{amount_all}\n") }
  end

  def self.total_oz
    bar     = @silver.select_total_oz(1) # 1: Bar
    junk    = @silver.select_total_oz(2) # 2: Junk
    bullion = @silver.select_total_oz(3) # 3: Bullion
    bar_amount     = get_silver_price(bar)     # Add amount of bars to the current price of Silver
    junk_amount    = get_silver_price(junk)    # Add amount of Junk to the current price of Silver
    bullion_amount = get_silver_price(bullion) # Add amount of Bullion to the current price of Silver
    total          = bar + junk + bullion
    amount_all     = bar_amount + junk_amount + bullion_amount
    rows = [['Bar Total OZ', bar, "$#{bar_amount}"],
            ['Junk Total OZ',       junk,    "$#{junk_amount}"],
            ['Bullion Total OZ',    bullion, "$#{bullion_amount}"],
            ['Total OZ',            total,   amount_all.to_s]]
    print_table(rows)
  end

  def self.select_bar
    @silver.select(1, html_table: false) # Bar
  end

  def self.select_junk
    @silver.select(2, html_table: false) # Junk
  end

  def self.select_bullion
    @silver.select(3) # Bullion
  end

  def self.select_cash
    @silver.select(4) # Cash
  end
  def self.select_gold
    @silver.select(5) # GOLD
  end
  def self.price_avg
    # Gets the avg price bought the different types of silver
    bar     = @silver.select_price_avg(1) # Bar
    junk    = @silver.select_price_avg(2) # Junk
    bullion = @silver.select_price_avg(3) # Bullion
    rows = [['Bar Price AVG', bar], ['Junk Price AVG', junk], ['Bullion Price AVG', bullion]]
    print_table(rows)
  end

  def self.franklins(html_table: false)
    # gets the count of franklin half dollars
    count = 0
    @silver.select_franklins.each do |c|
      c = c.dup
      c = c.shift
      count += c
    end
    # each Franklin half has 0.3617 oz of silver in
    return [count, count * 0.3617] if html_table


    rows = [['Franklin Half Count', count]]
    print_table(rows)
  end

  def self.method_of_purchase
    # creates a table of all the methods of purchases. For example
    # one method is that of Reddit.
    rows = @silver.select_method(1) # Bar
    print_table(rows, %w[Site Count], 'Bar Silver')
    rows = @silver.select_method(2) # Junk
    print_table(rows, %w[Site Count], 'Junk Silver')
    rows = @silver.select_method(3) # Bullion
    print_table(rows, %w[Site Count], 'Bullion Silver')
  end

  def self.display_all
    # This method will display all the data in nice little tables.
    bar_price_avg     = @silver.select_price_avg(1) # Bar
    junk_price_avg    = @silver.select_price_avg(2) # Junk
    bullion_price_avg = @silver.select_price_avg(3) # Bullion
    rows = [['Bar Price AVG', bar_price_avg],
            ['Junk Price AVG', junk_price_avg],
            ['Bullion Price AVG', bullion_price_avg]]
    print_table(rows)
    print("\n\n")
    bar_total_oz     = @silver.select_total_oz(1) # 1: Bar
    junk_total_oz    = @silver.select_total_oz(2) # 2: Junk
    bullion_total_oz = @silver.select_total_oz(3) # 3: Bullion
    bar_amt          = get_silver_price(bar_total_oz)     # Add amount of bars to the current price of Silver
    junk_amt         = get_silver_price(junk_total_oz)    # Add amount of Junk to the current price of Silver
    bullion_amt      = get_silver_price(bullion_total_oz) # Add amount of Bullion to the current price of Silver
    total_oz         = junk_total_oz + bar_total_oz + bullion_total_oz
    rows = [['Junk OZ Total', junk_total_oz, "$#{junk_amt}"],
            ['Bar OZ Total', bar_total_oz, "$#{bar_amt}"],
            ['Bullion OZ Total', bullion_total_oz, "$#{bullion_amt}"],
            ['Total OZ', total_oz.to_s, "$#{get_silver_price(total_oz)}"]]
    print_table(rows)
    print("\n\n")
    # Create a unicode table to show all the shipping total.
    bar_shipping_total     = @silver.shipping_total(1) # Bar
    junk_shipping_total    = @silver.shipping_total(2) # Junk
    bullion_shipping_total = @silver.shipping_total(3) # Bullion
    total = bar_shipping_total + junk_shipping_total + bullion_shipping_total
    rows = [['Bar Shipping Total', bar_shipping_total],
            ['Junk Shipping Total', junk_shipping_total],
            ['Bullion Shipping Total', bullion_shipping_total],
            ['Shipping Total', total]]
    print_table(rows)
    print("\n\n")
    results = @silver.sold_own
    # bar_own, junk_own, bar_sold, junk_sold, bullion_own, bullion_sold
    rows = [['Bar Own Count', results[0]],
            ['Junk Own Count', results[1]],
            ['Bar Sold Count', results[2]],
            ['Junk Sold Count', results[3]],
            ['Bullion Own Count', results[4]],
            ['Bullion Sold Count', results[5]]]
    print_table(rows)
    print("\n\n")
    rows = @silver.select_method(1) # Select Bar
    print_table(rows, %w[Site Count], 'Bar Silver')
    rows = @silver.select_method(2) # Selects Junk
    print_table(rows, %w[Site Count], 'Junk Silver')
    rows = @silver.select_method(3) # Select Bullion
    # print the table for bullion
    print_table(rows, %w[Site Count], 'Bullion Silver')

    select_sold_oz_total
  end

  def self.sold_vs_own
    # get all the sold items
    results = @silver.sold_own
    rows = [['Bar Own Count', results[0]],
            ['Junk Own Count', results[1]],
            ['Bar Sold Count', results[2]],
            ['Junk Sold Count', results[3]],
            ['Bullion Own Count', results[4]],
            ['Bullion Sold Count', results[5]]]
    print_table(rows)
  end

  def self.enter_bar
    @silver.input(1) # Enter new bar
  end

  def self.enter_junk
    @silver.input(2) # Enter new Junk
  end

  def self.change_own_status(row_id, id)
    @silver.update_own(row_id, id)
  end

  def self.enter_bullion
    @silver.input(3) # Enter new Bullion
  end

  def self.select_sold_total
    # Displays the sold total data in a nice table.
    bar_total     = @silver.sold_total(1) # 1: Bar
    junk_total    = @silver.sold_total(2) # 2: Junk
    bullion_total = @silver.sold_total(3) # 3: Bullion
    combine_total = bar_total + junk_total + bullion_total
    rows = [['Bar Sold Total',     bar_total],
            ['Junk Sold Total',    junk_total],
            ['Bullion Sold Total', bullion_total],
            ['Total of All Sold',  combine_total]]
    print_table(rows)
  end

  def self.select_sold_oz_total
    # displays the total oz that was sold in
    # a nice table
    bar_total     = @silver.sold_oz_total(1) # 1: Bar
    junk_total    = @silver.sold_oz_total(2) # 2: Junk
    bullion_total = @silver.sold_oz_total(3) # 3: Bullion
    combine_total = bar_total + junk_total + bullion_total
    rows = [['Bar Sold OZ Total',     bar_total],
            ['Junk Sold OZ Total',    junk_total],
            ['Bullion Sold OZ Total', bullion_total],
            ['Total OZ Sold',         combine_total]]
    print_table(rows)
  end

  def self.delete_row_by_id(row_id, id)
    # row_id is the id of row
    # id is the table id ( Bars, Junk, Bullion )
    @silver.delete_row(row_id, id)
  end

  def self.cash_input
    # intput cash information into the table Cash
    @silver.input_cash
  end

  def self.update_cash
    # add cash to the Cash table by row id
    print('Enter row ID: ')
    row_id = gets.chomp
    @silver.update_cash_own(row_id)
  end

  def self.read_save_file
    # gets the average of silver from the file "silver_total.txt"
    total = 0
    count = 0
    File.readlines('silver_total.txt').each do |line|
      line = line.dup
      line = line.split(' ')
      count += 1
      total += line[1].to_i
    end
    avg = total / count
    puts "AVG: #{avg}\n"
  end

  def self.silver_forecast
    # Enter amount of silver and see how much it is worth in USD
    print('Enter forecast silver OZ:')
    amount  = gets.chomp
    results = get_silver_price(amount)
    puts "Forecasted Silver Price: $#{results}"
  end

  def self.menu
    # Shows the menu in a nice table.
    rows = [[1, 'Select Junk'],
            [2, 'Select Bar'],
            [3, 'Select All Total OZ'],
            [4, 'Price AVG'],
            [5, 'Display All Info'],
            [6, 'Sold & Own Info'],
            [7, 'Enter New Bars'],
            [8, 'Find Franklins'],
            [9, 'Select Method of Purchase'],
            [10, 'Enter New Junk'],
            [11, 'Update Bar Own Status'],
            [12, 'Update Junk Own Status'],
            [13, 'Enter New Bullion'],
            [14, 'Select Bullion'],
            [15, 'Update Bullion Own'],
            [16, 'Sold total'],
            [17, 'Select Total OZ Sold'],
            [18, 'Copy Database file'],
            [19, 'Delete Row'],
            [20, 'Enter Cash'],
            [21, 'Select Cash'],
            [22, 'Update Cash Own Status'],
            [23, 'Save Current Price'],
            [24, 'AVG Current Price'],
            [25, 'Silver Forecast'],
            [26, 'Quit']]
    print_table(rows)
  end
end
