require 'active_support/time'

class BusFinder
  BUS_URL = 'http://www.nextbus.com/predictor/fancyNewPredictionLayer.jsp?a=lametro&r=720&s=16704'
  FINDER_START_HOUR = 9
  FINDER_START_MIN = 47
  FINDER_END_HOUR = 10
  FINDER_END_MIN = 00

  attr_reader :buses

  def initialize
    @buses = []
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
    return false unless (time.hour == FINDER_START_HOUR && time.min >= FINDER_START_MIN) ||
      (time.hour == FINDER_END_HOUR && time.min <= FINDER_END_MIN)
    true
  end
end