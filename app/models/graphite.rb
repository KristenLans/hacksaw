class Graphite
  require 'json'
  require 'net/http'

  #Graphite.new #cranks webservice call to graphite
  #graphite.json {:json from the server}
  #graphite.image #returns image URL
  #graphite.value #returns string from graphite
  
  attr_accessor :graphite_url

  
  def initialize(graphite_host)
    self.graphite_url = graphite_host
  end

  ## Sample /render Parameters
  # target = movingAverage(stats.timers.page_load_time.search.index.mean,10)
  # from = -136hours
  # to = -24hours

  def prepare_render_url(target, params = {})
    url = self.graphite_url + '/render/?target=' + target + '&format=json'
    params.each{ |key, value| url << "&#{key}=#{value}" unless key.blank? || value.blank? }
    url
  end

  def json(target, params = {})
    JSON.parse(Net::HTTP.get_response(URI.parse(prepare_render_url(target, params))).body)
  end

  def value(target, params = {})
    self.datapoints(target, params).last.first
  end

  def datapoints(target, params = {})
    self.json(target, params).first['datapoints']
  end

  def data_for_Google_annotated_time_chart(target, params = {})
    datapoints(target, params).collect do |data|
      value = data.first
      unix_time = data.last
      { date: Time.at(unix_time).strftime("new Date(%Y, %-m, %-d, %H, %M, %S)"), value: value }
    end.delete_if{ |d| d[:value].nil? }
  end

  def all_possible_metrics
    Rails.cache.fetch('all_metrics') do
      metrics = JSON.parse(Net::HTTP.get_response(URI.parse(self.graphite_url + '/metrics/index.json')).body)
      metrics.collect{ |m| m[1..-1] }
    end
  end

end

