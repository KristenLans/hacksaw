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
    self.all_datapoints(target, params).select{ |row| ! row[1].nil? }.last[1] || 0
  end

  def all_datapoints(target, params = {})
    datapoints_by_time = {}
    self.json(target, params).collect{ |t| t['datapoints'] }.each_with_index do |target_data, index|
      target_data.each do |row|
        datapoints_by_time[row[1]] ||= []
        datapoints_by_time[row[1]] << 0 until datapoints_by_time[row[1]].length == index
        datapoints_by_time[row[1]] << (row[0].nil? ? 0 : row[0])
      end
    end
    datapoints = []
    datapoints_by_time.each do |time, data|
      datapoints << [ time ] + data
    end
    datapoints
  end

  def data_for_Google_annotated_time_chart(target, params = {})
    converted_data = all_datapoints(target, params).collect! do |data|
      values = data[1..-1]
      unix_time = Time.at(data.first)
      { date: unix_time.javascript_date, values: values, unix_time: data.last }
    end
    converted_data.each_with_index.collect do |d, index|
      column_data = ([ d[:date] ] + d[:values]).join(",")
    end
  end

  def all_possible_metrics
    Rails.cache.fetch('all_metrics') do
      metrics = JSON.parse(Net::HTTP.get_response(URI.parse(self.graphite_url + '/metrics/index.json')).body)
      metrics.collect{ |m| m[1..-1] }
    end
  end

end
