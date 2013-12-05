#!/usr/bin/ruby

require 'rubygems'
require 'typhoeus'
require 'nokogiri'

response = Typhoeus.get('http://www.nextbus.com/predictor/fancyNewPredictionLayer.jsp?a=lametro&r=720&s=16704')
html = Nokogiri::HTML(response.body)
buses = []
buses << html.css('.predictionNumberForFirstPred .right').first.content
buses << html.css('.predictionNumberForOtherPreds .right').first.content
buses << html.css('.predictionNumberForOtherPreds .right').last.content
buses.map! {|b| b.gsub(/\n| /,'') }
prediction = buses.join(', ')
puts prediction
