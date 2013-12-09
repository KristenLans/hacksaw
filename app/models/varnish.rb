class Varnish
require 'net/http'
  def self.latest
    JSON.parse(Net::HTTP.get_response(URI.parse(ENV['graphite_endpoint'] + '/content/status.html')).body)
  end
end
