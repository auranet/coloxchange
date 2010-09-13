class QuoteMailer < ActionMailer::Base
  def quote_request_received(quote)
    @body["quote"] = quote
    from 'ColocationXchange <no-reply@colocationxchange.com>'
    recipients quote.contact.email
    subject 'Quote request received'
  end
end
