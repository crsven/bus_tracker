class BaseService
  def send_buses(predictions)
    times = predictions.join(', ')
    message = "Next buses in #{times} minutes"
    packet = build_packet(message)
    send_message packet
  end

  private

  def send_message(message)
    Typhoeus.post(@send_endpoint, body: message)
  end
end
