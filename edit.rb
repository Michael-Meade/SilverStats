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
for i in 20..60
  @db.execute("delete from Cash where id ='#{i}';")
end