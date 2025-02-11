# Jet Rockets Blog API

This README documents the steps necessary to get the application up and running.

## Ruby Version

- Ruby 3.4.1

## Rails Version

- Rails 8.0.1

## System Dependencies

- Ruby 3.4.1
- PostgreSQL 16.6
- Bundler 2.6.3

## Install required gems

Install gems

	$ bundle install

## Setup .env Configuration

This project uses environment variables stored in a `.env` file. To get started, create a `.env` file in the root directory by copying the example file:

	$ cp .env.example .env

Fill `DATABASE_USERNAME` and `DATABASE_PASSWORD` with your actual PostgreSQL username and password and `DATABASE_NAME` with your database name.

## Setup the database

Running command below will create development and test database and run migrations

	$ rails db:create && rails db:migrate

## Run application

You should be able to access your application at [http://localhost:3000](http://localhost:3000)

	$ rails s
	
## Seed database

With server up and running run the `seed.rb` script

	$ rails db:seed
