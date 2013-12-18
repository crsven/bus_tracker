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
    @html = Nokogiri::HTML(response.body)
    @buses << first_bus_time if first_bus_to_sm?
    @buses << second_bus_time if second_bus_to_sm?
    @buses << third_bus_time if third_bus_to_sm?
    @buses.map! {|b| b.gsub(/\n| /,'') }
  end

  private

  def within_finding_time
    time = Time.current.getlocal('-08:00')
    return false unless (time.hour == @finder_start_hour && time.min >= @finder_start_min) ||
      (time.hour == @finder_stop_hour && time.min <= @finder_stop_min)
    true
  end

  def first_bus_selector
    @html.css('.predictionNumberForFirstPred .right').first
  end

  def second_bus_selector
    @html.css('.predictionNumberForOtherPreds .right').first
  end

  def third_bus_selector
    @html.css('.predictionNumberForOtherPreds .right').last
  end

  def first_bus_time
    return 'Arriving' unless first_bus_selector
    first_bus_selector.content
  end

  def first_bus_to_sm?
    @html.css('.directionNameForPred').first.content.include? 'Santa Monica'
  end

  def second_bus_time
    return 'Arriving' unless second_bus_selector
    second_bus_selector.content
  end

  def second_bus_to_sm?
    @html.css('.directionNameForPred')[1].content.include? 'Santa Monica'
  end

  def third_bus_time
    return 'Arriving' unless third_bus_selector
    third_bus_selector.content
  end

  def third_bus_to_sm?
    @html.css('.directionNameForPred').last.content.include? 'Santa Monica'
  end
end
