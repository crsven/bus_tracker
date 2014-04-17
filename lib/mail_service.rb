class MailService < BaseService
  def initialize
    @send_endpoint = 'https://mandrillapp.com/api/1.0/messages/send.json'
  end

  def build_packet(subject)
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
