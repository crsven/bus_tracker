#!/usr/bin/ruby

require 'typhoeus'
require 'nokogiri'
require_relative '../lib/bus_finder'
require_relative '../lib/mail_service'

bus_finder = BusFinder.new
bus_finder.run
