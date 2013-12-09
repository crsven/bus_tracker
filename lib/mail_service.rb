class MailService
  SEND_ENDPOINT = 'https://mandrillapp.com/api/1.0/messages/send.json'

  def send_buses(predictions)
    times = predictions.join(', ')
    subject = "Next buses in #{times} minutes"
    new_message = message(subject)
    send_message new_message
  end

  private

  def send_message(message)
    Typhoeus.post(SEND_ENDPOINT, body: message)
  end

  def message(subject)
    {
      key: ENV['MANDRILL_APIKEY'],
      message: {
        subject: subject,
        from_email: 'noreply@example.com',
        from_name: 'Your friendly neighborhood bus tracker',
        to: [
          {
            email: 'crsven@gmail.com',
            name: 'Chris Svenningsen',
            type: 'to',
          }
        ],
      }
    }
  end
end
