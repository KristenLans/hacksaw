class Graphite# < ActiveRecord::Base
  require 'net/http'

  #Graphite.new #cranks webservice call to graphite
  #graphite.json {:json from the server}
  #graphite.image #returns image URL
  #graphite.value #returns string from graphite
  
  attr_accessor :graphite_url

  
  def initialize(graphite_host)
    self.graphite_url = graphite_host
   
  end

  def json(target,params)
    JSON.parse(Net::HTTP.get_response(URI.parse(self.graphite_url + '/render/?target=' + target + '&' + params + '&format=json')).body)
  end

  def value(target,params)
    self.datapoints(target,params).last.first
  end

  def datapoints(target,params)
    self.json(target,params).last['datapoints']
  end

  #from=-136hours&to=-24hours
  #movingAverage(stats.timers.page_load_time.search.index.mean,10)

end

