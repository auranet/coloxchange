class PhobosTicket < ActiveResource::Base
  @headers = {"X_INKDROP_TOKEN" => "test"}
  self.element_name = "ticket"
  self.site = "http://localhost:3000"

  def url
    "http://my.x451.com/tickets/#{self.id}"
  end
end