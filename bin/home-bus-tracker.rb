#!/usr/bin/ruby

require 'typhoeus'
require 'nokogiri'
require_relative '../lib/bus_finder'
require_relative '../lib/mail_service'

bus_finder = BusFinder.new
mail_service = MailService.new

bus_finder.find_buses!
mail_service.send_buses(bus_finder.buses)
