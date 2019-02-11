require 'net/http'
class SMSApi
  attr_accessor :client
  attr_accessor :uri

  def initialize
    @uri = uri
    return unless @uri
    @client = Net::HTTP.new(@uri.host, @uri.port)
  end

  def uri
    return unless end_point_available?
    URI.parse(Rails.application.secrets.sms_end_point)
  end

  def sms_deliver(phone, code)
    return stubbed_response unless end_point_available?
    request = Net::HTTP::Post.new(@uri.request_uri)
    request.set_form_data(request(phone, code))
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request["key"] = Rails.application.secrets.sms_password
    response = @client.request(request)
    success?(response)
  end

  def request(phone, code)
    { "dst"=> phone,
      "src" => "Ayto El Rosario",
      "msg" => "Clave para verificarte: #{code}. Participa",
    }
  end

  def success?(response)
    xml = Nokogiri::XML(response.body)
    xml.xpath('numSMS').text == '1'
  end

  def end_point_available?
    Rails.env.staging? || Rails.env.preproduction? || Rails.env.production? || Rails.env.development?
  end

  def stubbed_response
      0#23419
  end

end
