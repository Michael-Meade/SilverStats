
require_relative 'test2'
silver = Inventory.new
pre_names = [] 
silver.select_method(1, html_table: false).each { |info| pre_names << info }

silver.select_method(2, html_table: false).each { |info| pre_names << info }

silver.select_method(3, html_table: false).each { |info| pre_names << info }

names = {}
i = 0
pre_names.each do |name, count|
  if !names.key?(name)
    names[name] = count
  else
    names[name] +=  count
  end
end
p names.to_a
