# SilverStats

Note that the database included and shown is not my real stack information. I do not want to show
that inforamtion because it's bad op sec.


## Menu 
This takes a number. Right now it is 1 through 18..
![menu of the program](images/menu.png)

## Select Total
This feature will display all the total oz in Bullion, Junk and Bars tables. It will also use 
duckduck go search to display how much the silver total is in USD. 
![Select all total oz](images/select_all_total_oz.png)

## Price AVG
The image below shows that it will show text in red if there is a error with 
determining the avg. 
![Price AVG](images/price_avg.png)

## Sold Total
Get the total of all Sold items.<br>
![Sold Total](images/sold_total.png)

## Update Sold Value
Update the sold value. This is used when you sell one of your piece of silver.<br>
![Sold Value](images/update_sold.png)

## Forecast Silver
This feature will take the inputed silver amount and use Duck Duck Go API to
get how much the amount of silver is worth in USD. <Br>
![Forecase Silver](images/forecast_silver.png)

## Back Up DB
This will back up the db by saving a copy of it with a new name. <br>
![BackUp DB](images/backup_db.png)

## WEBSITE

### Change Status
The status can either be `sold` or `own`. By entering the row ID it will automatically change the status via the current status. Like for example,
if the status is `sold` it will change to `own` and if it set to `own` it will change to `sold`.
![Change status](images/change_status.png)

### Delete Row

This page will display a nice html table that includes the row id. The user will
enter the row id which will delete the row. 
![Deleting row](images/delete_row.png)

### Entering Silver
The enter silver page has three buttons, one to change status, delete a certain row and enter silver. They are color coded as your can see below.
![Entering Silver](images/enter_silver.png)


### Pie Charts
Shows the percentage of different types of silver and cryptocurrency. 
![Pie charts showing the types of silver](images/pie_chart.png)

### Cryptocurrency table
Reads from JSON file. Can be set by using `EXPORT=stats2.json`
![crypto table](images/crypto.png)


### Silver Stats

![silver status](images/silver_stats.png)

## Running the website

```ruby
	ruby run.rb
```

There are two crypto json files, `prod.json` and `dev.json`. There will be a text in the crypto tag with the color red if 
`dev.json` is being used. If the `prod.json` is active it will show green text.

### Install Gems

Note that sqlite3 can sometimes be a pain to install. I have trouble in the past. Also gruff uses `rmagick` which in turn uses `ImageMagick`. Which can be a pain to install correctly. 


Install magick: `sudo apt-get install libmagickwand-dev`.

I had to install this too: `sudo apt update && sudo apt install build-essential   `

```ruby
sudo apt-get install sqlite3

sudo apt install ruby-dev
```

```ruby
gem install gruff
gem install sqlite3
gem install CryptoPriceFinder
gem install sinatra
gem install httparty
gem install rack -v 3.1.12
gem install dotenv
gem install logger -v 1.5.3
gem install terminal-table
gem install colorize
gem install rackup puma

```

### Set password
You will need to export a var named PASS to be able to get to the page. The username's is `admin`.
Use this: `export PASS='Y0urPa$sw0rdzz!1989'`

Might want to put this in your `.bashrc` file. Use `source .bashrc` after making the change to the file.