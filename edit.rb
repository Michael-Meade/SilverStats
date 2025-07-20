require 'sqlite3'
require_relative 'test2'
@db = SQLite3::Database.new 'test2.db'
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
bull_meth = []
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

def edit_date(table)
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

edit_date("Bullion")
edit_date("Junk")