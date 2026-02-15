require 'date'
require 'fileutils'
task default: %w[rm]
desc "delete files"
task :rm do
  files_not_delete = ["app.log","logs.txt","test2.db"]
end


desc "Make a backup of the databases"
task :db_backup do
  d = DateTime.now
  date = d.strftime("%m-%d-%Y")
  # Loops through all the files that have *.db
  Dir.glob("*.db").each do |filename|
    # creat the file path with the date
    file_path = File.join("/root", "db_backups", date)
    # makes a new folder with todays date
    Dir.mkdir file_path unless File.exist?(file_path)
    # copies all the .db files to the folder with the current dates
    FileUtils.cp(filename, File.join("/root", "db_backups", date, filename))
  end
end