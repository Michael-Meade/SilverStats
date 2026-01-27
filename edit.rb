# Script to edit things and manage
# Ignore this
#

require 'sqlite3'
require_relative 'test2'
@db = SQLite3::Database.new 'test2.db' 
#'test2.db'
#@db.execute("UPDATE Bar SET method = 'APMEX' WHERE id='5';")
#@db.execute("UPDATE Bar SET seller = 'APMEX' WHERE id='5';")

=begin
@db.execute("UPDATE Bar SET method = 'APMEX' WHERE id='2';")
@db.execute("UPDATE Bar SET seller = 'APMEX' WHERE id='2';")

@db.execute("UPDATE Bar SET method = 'APMEX' WHERE id='3';")
@db.execute("UPDATE Bar SET seller = 'APMEX' WHERE id='3';")
=end

def delete_cash
  for i in 20..60
    @db.execute("delete from Cash where id ='#{i}';")
  end
end

def sellers
  # ma
  total = 0

  @db.execute("select total from Bullion where seller = 'APMEX';").each { |amount| a_total += amount.shift }

  @db.execute("select total from Bar where seller = 'APMEX';").each { |amount| a_total += amount.shift }

  @db.execute("select total from Junk where seller = 'APMEX';").each { |amount| a_total += amount.shift }


  p total

  # JMbullion
  total = 0
  @db.execute("select total from Bullion where seller = 'JMbullion';").each { |amount| total += amount.shift }
  @db.execute("select total from Bar where seller = 'JMbullion';").each { |amount| total += amount.shift }
  @db.execute("select total from Junk where seller = 'JMbullion';").each { |amount| total += amount.shift }
  p total

  # Golden State Mint
  total = 0
  @db.execute("select total from Bullion where seller = 'Golden State Mint';").each { |amount| total += amount.shift }
  @db.execute("select total from Bar where seller = 'Golden State Mint';").each { |amount| total += amount.shift }
  @db.execute("select total from Junk where seller = 'Golden State Mint';").each { |amount| total += amount.shift }
  p total


  # MoneyMetals
  total = 0
  @db.execute("select total from Bullion where seller = 'MoneyMetals';").each { |amount| total += amount.shift }
  @db.execute("select total from Bar where seller = 'MoneyMetals';").each { |amount| total += amount.shift }
  @db.execute("select total from Junk where seller = 'MoneyMetals';").each { |amount| total += amount.shift }
  p total
end
=begin
@db.execute("select method from Bullion;").each do |m|
  m = m.shift
  if !bull_meth.include?(m)
    bull_meth << m
  end
end

=end
=begin
c = []
silver = Inventory.new
cash =  silver.select(4, html_table: true) 
cash.each do |i|
  if i[3].eql?("own")
    c << [ i[2], i[4] ]
  end
end
p c
=end
require 'securerandom'

puts 
def edit_date(table)
  # changes to make the date Month/Day/Year 
    @db.execute("select id, bought_date from #{table};").each do |id, date|
    begin
      new_date = Date.strptime(date,'%m/%d/%Y')
      puts new_date
      @db.execute("UPDATE #{table} SET bought_date = '#{new_date}' WHERE id='#{id}';")
    rescue
      puts "DATE: #{date}\n"
    end
  end
  #@db.execute("UPDATE Bullion SET seller = 'APMEX' WHERE id='3';")
end

#edit_date("Bullion")
#edit_date("Junk")
#@db.execute('create table IF NOT EXISTS CashTest (id integer primary key, amount integer, recipient text, status text, spent_amount integer);')

#@db.execute('create table IF NOT EXISTS JunkTest (id integer primary key, amount integer, recipient text, status text, spent_amount integer);')

def change_id(new_table)
  # Testing the new ID systems
  t = @db.execute("select * from #{new_table}Test;")
  @db.execute("select * from Bullion;").each do |i|
    uuid = SecureRandom.random_number(99999999)
    i[0] = uuid
    p i
    @db.execute("insert into #{new_table}Test values (?,?,?,?,?,?,?,?,?,?,?,?,?)",i)
  end
  t = @db.execute("select * from #{new_table}Test;")
  p t
end

def change_name(table)
  @db.execute("drop table #{table};")
  @db.execute("ALTER TABLE `#{table}Test` RENAME TO `#{table}`")
end

#change_name("Bar")
#p @db.execute("select * from BullionTest;")

#change_id("Bar")

#change_name("Bar")


#@db.execute("drop table Junk;")
#@db.execute("ALTER TABLE `JunkTest` RENAME TO `Junk`")

#p @db.execute("select * from Junk")
=begin
@db.execute("create table IF NOT EXISTS Junk (id integer primary key, bought_date text,
              spot_price INTEGER,
              amount INTEGER,
              price real,
              shippinBar
              total real,
              oz INTEGER,
              name text,
              status text,
              sold_value INTEGER,
              seller text,
              method text);")
=end

#change_id("Bar")

=begin
#@db.execute("create table IF NOT EXISTS Bar (id integer primary key, bought_date text,
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
=end
@db.execute("drop table Bar")