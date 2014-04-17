class PushoverService < BaseService
  def initialize
    @send_endpoint = 'https://api.pushover.net/1/messages.json'
  end

  def build_packet(message)
    {
      token: ENV['PUSHOVER_API_KEY'],
      user: ENV['PUSHOVER_USER_KEY'],
      message: message
    }
  end
end
