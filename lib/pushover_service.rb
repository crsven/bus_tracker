class PushoverService < BaseService
  def initialize
    @send_endpoint = 'https://api.pushover.net/1/messages.json'
  end

  def build_packet(message)
    {
      token: ENV['BUS_TRACKER_PUSHOVER_API_KEY'],
      user: ENV['BUS_TRACKER_PUSHOVER_USER_KEY'],
      message: message
    }
  end
end
