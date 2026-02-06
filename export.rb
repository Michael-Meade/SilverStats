# This class will export data from the tables into a CSV file. 
require_relative 'lib'
require 'csv'
require 'securerandom'
require 'date'
class Export < Inventory
	def types_of_silver
		{
			"Bar": 1,
			"Junk": 2,
			"Bullion": 3
		}
	end
	def create_csv
		# This is used for two purposes. First to make sure it
		# is impossible to guess the file name. 
		# Second reason is make each creation of the csv
		# unique file name each time the csv is created and not over written
		uid = SecureRandom.uuid
		# Create and add the data to the CSV
		d = DateTime.now
		date = d.strftime("%m-%d-%Y")
		# saves the generated file_names in an array. For them to be 
		# downloaded
		save_file_name = []
		# Get the name of type of silver (junk,bullion,bars)
		# and the id of silver which is used to obtain the data
		types_of_silver.each do |name, id|
			# Uses securerandom to create a uid for the filename
			file_name = "#{name}_#{date}_#{uid}.csv"
			# gets the row data
			data = self.select(id, html_table: true)
			# The headers for the csv
			headers = ["ID", "Bought Date", "Spot Price", "Amount", "Price", "Shipping", "Total", "OZ", "Name", "Status", "Sold Value", "Seller", "Method"] 
			# Saves the data in a csv with a filename like: junk_02-06-2026_2d931510-d99f-494a-8c67-87feb05e1594.csv
			# in the "spreadsheets_output folder"
			CSV.open(File.join("spreadsheets_output", file_name), "a", :write_headers => true, :headers => headers) do |csv|
				data.each do |row|
					csv << row
				end
			save_file_name << file_name
			end
		end
	return save_file_name
	end
end

=begin
rows = Export.new


p rows.create_csv
=ed





