class GraphiteRequest

  attr_accessor :graphite_host, :target, :params, :json, :datapoints

  ## Sample /render Parameters
  # target = movingAverage(stats.timers.page_load_time.search.index.mean,10)
  # from = -136hours
  # to = -24hours

  def initialize(graphite_host, target, params = {})
    self.graphite_host = graphite_host
    self.target = target
    self.params = params
    self.json = json_response
  end

  # returns the value of the last non-nil row, which will be the latest value
  def value
    all_datapoints.select{ |row| ! row[1].nil? }.last[1] || 0
  end

  # will return an array with entries for each time.
  # rows will have at least one, but may have two or more values, e.g.
  #   [ [ time1, valueA,  (valueB, valueC, ...)     ] ,
  #     [ time2, valueA,  (valueB, valueC, ...)     ] ]
  def all_datapoints
    return self.datapoints if self.datapoints
    datapoints_by_time = {}
    json.collect{ |t| t['datapoints'] }.each_with_index do |target_data, index|
      target_data.each do |row|
        next if row[0].nil? && params[:ignore_if_nil]
        datapoints_by_time[row[1]] ||= []
        datapoints_by_time[row[1]] << 0 until datapoints_by_time[row[1]].length == index
        datapoints_by_time[row[1]] << (row[0].nil? ? 0 : row[0])
      end
    end
    datapoints = []
    datapoints_by_time.each do |time, data|
      datapoints << [ time ] + data
    end
    self.datapoints = datapoints
  end

  def data_for_Google_annotated_time_chart
    converted_data = all_datapoints.collect! do |data|
      values = data[1..-1]
      unix_time = Time.at(data.first)
      { date: unix_time.javascript_date, values: values, unix_time: data.last }
    end
    converted_data.each_with_index.collect do |d, index|
      column_data = ([ d[:date] ] + d[:values]).join(",")
    end
  end

  def json_response
    request_uri = URI.parse(prepare_render_url)
    JSON.parse(Net::HTTP.get_response(request_uri).body)
  end

  def prepare_render_url
    url = self.graphite_host.base_url + '/render/?target=' + self.target + '&format=json'
    params.each{ |key, value| url << "&#{key}=#{value}" unless key.blank? || value.blank? }
    url
  end

end
