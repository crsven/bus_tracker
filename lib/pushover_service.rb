class PushoverService
  SEND_ENDPOINT = 'https://api.pushover.net/1/messages.json'

  def send_buses(predictions)
    times = predictions.join(', ')
    message = "Next buses in #{times} minutes"
    packet = build_packet(message)
    send_message packet
  end

  private

  def send_message(message)
    Typhoeus.post(SEND_ENDPOINT, body: message)
  end

  def build_packet(message)
    {
      token: ENV['PUSHOVER_API_KEY'],
      user: ENV['PUSHOVER_USER_KEY'],
      message: message
    }
  end
end
