class ZendeskSender
  attr_accessor :ticket_payload

  def self.call(ticket_payload)
    new(ticket_payload).call
  end

  def initialize(ticket_payload)
    @ticket_payload = ticket_payload
    @return_hash = {}
  end

  def call
    create_ticket
    @return_hash[:success] = true
    @return_hash[:response_message] = "#{feedback_type.titleize} submitted"
    @return_hash
  rescue ZendeskAPI::Error::ClientError => e
    catch_error(e)
    @return_hash
  end

  private

  def create_ticket
    ZendeskAPI::Ticket.create!(
      ZENDESK_CLIENT,
      **base_params,
      **email_params,
      **custom_params
    )
  end

  def catch_error(error)
    @return_hash[:response_message] = "Unable to submit #{feedback_type.downcase}"
    @return_hash[:success] = false
    LogStuff.error(class: self.class.name, action: 'save', error_class: error.class.name, error: error.to_s) do
      "#{feedback_type.titleize} submission failed!"
    end
  end

  def feedback_type
    ticket_payload.type.humanize
  end

  def base_params
    {
      subject: ticket_payload.subject,
      description: ticket_payload.description
    }
  end

  def email_params
    return {} if ticket_payload.reporter_email.blank?

    { email_ccs: [{ user_email: ticket_payload.reporter_email }] }
  end

  def custom_params
    {
      custom_fields: [
        { id: '26047167', value: ticket_payload.referrer },
        { id: '23757677', value: 'advocate_defence_payments' },
        { id: '23791776', value: ticket_payload.user_agent },
        { id: '32342378', value: Rails.host.env }
      ]
    }
  end
end
