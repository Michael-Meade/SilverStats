# frozen_string_literal: true

require_relative 'lib'
loop do
  print("\n\n\n\n")
  Silver.menu
  print('Enter choice:')
  choice = gets.chomp
  print("\n\n\n")
  case choice.to_i
  when 1
    # dispaly the Junk table
    Silver.select_junk
    sleep 10
  when 2
    # Display the bar table
    Silver.select_bar
    sleep 10
  when 3
    # Show unicode table of total oz
    Silver.total_oz
    sleep 10
  when 4
    Silver.price_avg
    sleep 10
  when 5
    # display all the amounts in nice unicode table
    Silver.display_all
    sleep 10
  when 6
    Silver.sold_vs_own
    sleep 10
  when 7
    # Enter new bars into the Bar table.
    Silver.enter_bar
    sleep 10
  when 8
    # Show franklin count
    Silver.franklins
    sleep 10
  when 9
    # prints the method of purchase in a nice
    # unicode terminal that is green
    Silver.method_of_purchase
    sleep 10
  when 10
    # Enter junk silver into the Junk
    # table
    Silver.enter_junk
    sleep 10
  when 11
    print('Enter Row ID:')
    row_id = gets.chomp
    # Bars - update own and/or sold
    Silver.change_own_status(row_id, 1)
  when 12
    print('Enter Row ID:')
    row_id = gets.chomp
    # Junk - update own and/or sold
    Silver.change_own_status(row_id, 2)
  when 13
    # Enter Bullion
    Silver.enter_bullion
    sleep 10
  when 14
    # Select Bullion
    Silver.select_bullion
    sleep 10
  when 15
    # Bullion - update own and/or sold
    print('Enter Row ID: ')
    row_id = gets.chomp
    Silver.change_own_status(row_id, 3)
    sleep 10
  when 16
    Silver.select_sold_total
    sleep 10
  when 17
    Silver.select_sold_oz_total
    sleep 10
  when 18
    # copy DB file
    print('Enter DB File you want to copy: ')
    file_to_copy = gets.chomp
    if File.exist?(file_to_copy)
      print('Enter the new name you want to name the db:')
      new_name = gets.chomp
      FileUtils.cp(file_to_copy, new_name)
    else
      puts "#{file_to_copy} does not exist.\n".red
    end
    sleep 10
  when 19
    menu = "1) Delete Bar row\n2) Delete Junk row\n3) Delete Bullion row4\n4) Delete Cash row\n\n\n\n"
    print(menu)
    print('Enter Option: ')
    option = gets.chomp
    print("\n\n")
    print('Enter Row ID: ')
    row_id = gets.chomp
    case option.to_i
    when 1
      # Delete certain row from Bar table
      Silver.delete_row_by_id(row_id, 1)
      # Display the bar table
      Silver.select_bar
    when 2
      # Delete certain row from Junk Table
      Silver.delete_row_by_id(row_id, 2)
      Silver.select_junk # display the junk table
    when 3
      # Bullion
      Silver.delete_row_by_id(row_id, 3)
      Silver.select_bullion
    when 4
      # Cash
      Silver.delete_row_by_id(row_id, 4)
      Silver.select_cash
    else
      puts 'Invalid option....'
    end
    sleep 10
  when 20
    # Enter new cash information into the
    # cash table.
    Silver.cash_input
    sleep 30
  when 21
    # Display the cash table
    Silver.select_cash
    sleep 30
  when 22
    # Update cash own status
    Silver.update_cash
    sleep 10
  when 23
    Silver.save_total_oz
    sleep 10
  when 24
    Silver.read_save_file
    sleep 30
  when 25
    Silver.silver_forecast
    sleep 30
  when 26
    exit
  end
end
