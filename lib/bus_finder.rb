class BusFinder
  BUS_URL = 'http://www.nextbus.com/predictor/fancyNewPredictionLayer.jsp?a=lametro&r=720&s=16704'

  attr_reader :buses

  def initialize
    @buses = []
  end

  def find_buses!
    response = Typhoeus.get(BUS_URL)
    html = Nokogiri::HTML(response.body)
    @buses << html.css('.predictionNumberForFirstPred .right').first.content
    @buses << html.css('.predictionNumberForOtherPreds .right').first.content
    @buses << html.css('.predictionNumberForOtherPreds .right').last.content
    @buses.map! {|b| b.gsub(/\n| /,'') }
  end
end
