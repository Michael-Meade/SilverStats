# This class will export data from the tables into a CSV file. 
require_relative 'lib'
require 'csv'
require 'date'
class Export < Inventory
	def get_junk
		self.select(2, html_table: true)
	end
	def create_csv(data, name)
		# Create and add the data to the CSV
		d = DateTime.now
		date = d.strftime("%m-%d-%Y")
		headers = ["ID", "Bought Date", "Spot Price", "Amount", "Price", "Shipping", "Total", "OZ", "Name", "Status", "Sold Value", "Seller", "Method"] 
		CSV.open("#{name}_#{date}.csv", "a", :write_headers => true, :headers => headers) do |csv|
			data.each do |j|
				csv << j
			end
		end
	end
end

rows = Export.new

junk_rows = rows.get_junk


rows.create_csv(junk_rows, "Junk")




