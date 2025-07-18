
require_relative 'test2'
silver = Inventory.new
gold    = silver.select_total_oz(5)

p Silver.get_gold_price(gold)