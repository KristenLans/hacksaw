class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'application'

  DEFAULT_TIME_RANGE = '-1week'

  def index
    g = Graphite.new(Hacksaw::Application.config.graphite_endpoint)
    @taxa_page_load_time_data = g.data_for_Google_annotated_time_chart(
      'movingAverage(stats.timers.page_load_time.taxa-overview.show.mean_90,50)' +
      '&target=movingAverage(stats.timers.page_load_time.taxa-overview.show.mean_90,500)', from: DEFAULT_TIME_RANGE)
    @home_page_load_time_data = g.data_for_Google_annotated_time_chart(
      'movingAverage(stats.timers.page_load_time.content.index.mean_90,50)' +
      '&target=movingAverage(stats.timers.page_load_time.content.index.mean_90,500)', from: DEFAULT_TIME_RANGE)
    @api_searches = g.data_for_Google_annotated_time_chart(
      'hitcount(stats.timers.page_load_time.api.search.count_ps,\'1hour\')', from: DEFAULT_TIME_RANGE)
    @slave_lag = g.data_for_Google_annotated_time_chart(
      'eol-db-slave1.mysql.general.slaveLag', from: DEFAULT_TIME_RANGE)
    varnish = Varnish.latest
    @servers_online = varnish.map{|server| server['health'] == "Healthy"}.count(true)
    @servers_offline = varnish.map{|server| server['health'] == "Healthy"}.count(false)
    @servers_total = @servers_online + @servers_offline
    @recent_taxon_page_load_time = g.value('movingAverage(stats.timers.page_load_time.taxa-overview.show.mean_90,500)', from: '-1day')
    @current_taxon_page_load_time = g.value('movingAverage(stats.timers.page_load_time.taxa-overview.show.mean_90,50)', from: '-1day')
    @recent_search_api_load_time = g.value('movingAverage(stats.timers.page_load_time.api.search.mean_90,500)', from: '-1day')
    @current_search_api_load_time = g.value('movingAverage(stats.timers.page_load_time.api.search.mean_90,50)', from: '-1day')
    @current_slave_lag = g.value('eol-db-slave1.mysql.general.slaveLag', from: '-1minute')
  end
end
