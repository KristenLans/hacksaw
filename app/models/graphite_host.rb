class GraphiteHost

  #Graphite.new #cranks webservice call to graphite
  #graphite.json {:json from the server}
  #graphite.image #returns image URL
  #graphite.value #returns string from graphite

  attr_accessor :base_url

  def initialize(url)
    self.base_url = url
  end

  def self.connection
    GraphiteHost.new(Hacksaw::Application.config.graphite_endpoint)
  end

  def query(target, params = {})
    GraphiteRequest.new(self, target, params)
  end

  def all_possible_metrics
    Rails.cache.fetch('all_metrics') do
      metrics = JSON.parse(Net::HTTP.get_response(URI.parse(self.base_url + '/metrics/index.json')).body)
      metrics.collect{ |m| m[1..-1] }
    end
  end

end
