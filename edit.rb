require 'sqlite3'
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


total = 0

@db.execute("select total from Bullion where seller = 'APMEX';").each { |amount| total += amount.shift }

@db.execute("select total from Bar where seller = 'APMEX';").each { |amount| total += amount.shift }

@db.execute("select total from Junk where seller = 'APMEX';").each { |amount| total += amount.shift }


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