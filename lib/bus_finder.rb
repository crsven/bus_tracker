require 'active_support/time'

class BusFinder
  BUS_URL = 'http://www.nextbus.com/predictor/fancyNewPredictionLayer.jsp?a=lametro&r=720&s=16704'

  attr_reader :buses

  def initialize(use_mail_fallback=false)
    @buses = []
    @finder_start_hour = ENV['BUS_FINDER_START_HOUR'].to_i
    @finder_start_min = ENV['BUS_FINDER_START_MIN'].to_i
    @finder_stop_hour = ENV['BUS_FINDER_STOP_HOUR'].to_i
    @finder_stop_min = ENV['BUS_FINDER_STOP_MIN'].to_i
    @notification_service = if use_mail_fallback
                              MailService.new
                            else
                              PushoverService.new
                            end
  end

  def run
    while true do
      find_buses
      handle_buses unless buses.empty?
      sleep 60.0
    end
  end

  def handle_buses
    @notification_service.send_buses(buses)
    buses.clear
  end

  def find_buses
    return unless within_finding_time

    response = Typhoeus.get(BUS_URL)
    @html = Nokogiri::HTML(response.body)
    begin
      check_bus(first_bus)
      check_bus(second_bus)
      check_bus(third_bus)
    rescue NoMethodError => e
      puts e
      puts @html.css('.directionNameForPred')
    end
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
    time = Time.current.in_time_zone('Pacific Time (US & Canada)')
    date = Date.current
    return false unless (1..5).to_a.include?(date.wday)
    return false unless (time.hour == @finder_start_hour && time.min >= @finder_start_min) ||
      (time.hour == @finder_stop_hour && time.min <= @finder_stop_min)
    true
  end

  def check_bus(bus)
    time_string = bus_time(bus)
    time = time_string.scan(/\d+/).first.to_i
    log_bus(bus)
    @buses << time_string if bus_to_sm?(bus) && time.to_i > 7
  end

  def log_bus(bus)
    puts "#{bus[:time_selector]} #{bus[:destination_text]}"
  end

  def bus_time(bus)
    return "0" unless bus[:time_selector]
    bus[:time_selector].content
  end

  def bus_to_sm?(bus)
    bus[:destination_text].include? 'Santa Monica'
  end
end
