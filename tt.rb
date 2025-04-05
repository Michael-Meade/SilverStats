require 'terminal-table'
table = Terminal::Table.new do |t|
  t.add_row [1, 'One']
  t.add_row [2, 'Two']
  t.add_row [3, 'Three']
  t.style = {:all_separators => true}
  t.style = {border: :unicode}
end
rows = table.elaborate_rows
rows[2].border_type = :heavy # modify separator row: emphasize below title
puts table.render
def test(rows)
  t = Terminal::Table.new
  t.rows  =  rows
  t.style = {:all_separators => true}
  t.style = {border: :unicode}
  puts t.render
end
a =  [[1, "1", "1"], [2, "2", "2"], [3,"3", "3"]]
test(a)