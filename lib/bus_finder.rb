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
    check_bus(first_bus)
    check_bus(second_bus)
    check_bus(third_bus)
    @buses.map! {|b| b.gsub(/\n| /,'') }
  end

  private

  def first_bus
    {
      time_selector: @html.css('.predictionNumberForFirstPred .right').first,
      destination_text: @html.css('.directionNameForPred').first.content,
    }
  end

  def second_bus
    {
      time_selector: @html.css('.predictionNumberForOtherPreds .right').first,
      destination_text: @html.css('.directionNameForPred')[1].content,
    }
  end

  def third_bus
    {
      time_selector: @html.css('.predictionNumberForOtherPreds .right').last,
      destination_text: @html.css('.directionNameForPred').last.content,
    }
  end

  def within_finding_time
    time = Time.current.getlocal('-08:00')
    return false unless (time.hour == @finder_start_hour && time.min >= @finder_start_min) ||
      (time.hour == @finder_stop_hour && time.min <= @finder_stop_min)
    true
  end

  def check_bus(bus)
    @buses << bus_time(bus) if bus_to_sm?(bus)
  end

  def bus_time(bus)
    return 'Arriving' unless bus[:time_selector]
    bus[:time_selector].content
  end

  def bus_to_sm?(bus)
    puts bus[:destination_text]
    bus[:destination_text].include? 'Santa Monica'
  end
end
