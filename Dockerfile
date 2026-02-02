FROM ruby:3.3.8
RUN apt update
RUN apt upgrade
RUN sudo apt-get install libmagickwand-dev
RUN sudo apt install ruby-dev
RUN sudo apt install build-essential
RUN gem install sqlite3
RUN gem install gruff



RUN gem install sinatra
RUN gem install httparty
RUN gem install rack -v 3.1.12
RUN gem install dotenv
RUN gem instal colorize
RUN gem install terminal-table
RUN gem install logger -v 1.5.3
RUN gem install gem install CryptoPriceFinder
RUN gem install rackup puma