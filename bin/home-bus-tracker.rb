#!/usr/bin/ruby

require 'typhoeus'
require 'nokogiri'
require_relative '../lib/bus_finder'
require_relative '../lib/mail_service'
require_relative '../lib/pushover_service'

bus_finder = BusFinder.new ARGV[0]
bus_finder.run
