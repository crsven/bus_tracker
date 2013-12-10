require 'active_support/time'

class BusFinder
  BUS_URL = 'http://www.nextbus.com/predictor/fancyNewPredictionLayer.jsp?a=lametro&r=720&s=16704'

  attr_reader :buses

  def initialize
    @buses = []
    @finder_start_hour = ENV['BUS_FINDER_START_HOUR'].to_i
    @finder_start_min = ENV['BUS_FINDER_START_MIN'].to_i
    @finder_stop_hour = ENV['BUS_FINDER_STOP_HOUR'].to_i
    @finder_stop_min = ENV['BUS_FINDER_STOP_MIN'].to_i
  end

  def find_buses!
    return unless within_finding_time

    response = Typhoeus.get(BUS_URL)
    html = Nokogiri::HTML(response.body)
    @buses << html.css('.predictionNumberForFirstPred .right').first.content
    @buses << html.css('.predictionNumberForOtherPreds .right').first.content
    @buses << html.css('.predictionNumberForOtherPreds .right').last.content
    @buses.map! {|b| b.gsub(/\n| /,'') }
  end

  private

  def within_finding_time
    time = Time.current.getlocal('-08:00')
    return false unless (time.hour == @finder_start_hour && time.min >= @finder_start_min) ||
      (time.hour == @finder_stop_hour && time.min <= @finder_stop_min)
    true
  end
end
