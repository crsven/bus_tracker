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

message = {
  key: ENV['MANDRILL_APIKEY'],
  message: {
    subject: "#{prediction}",
    from_email: 'noreply@example.com',
    from_name: 'Your friendly neighborhood bus tracker',
    to: [
      {
        email: 'crsven@gmail.com',
        name: 'Chris Svenningsen',
        type: 'to',
      }
    ],
  }
}

send_endpoint = 'https://mandrillapp.com/api/1.0/messages/send.json'
result = Typhoeus.post(send_endpoint, body: message)
puts result
