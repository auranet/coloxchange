class QuoteMailer < ActionMailer::Base
  def quote_request_received(quote)
    @body["quote"] = quote
    from 'noreply@coloxchange.net'
    recipients quote.contact.email
    subject 'Quote request received'
  end
end
