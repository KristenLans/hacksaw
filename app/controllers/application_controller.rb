class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'application'

  DEFAULT_TIME_RANGE = '-2weeks'

  def index
    g = Graphite.new(Hacksaw::Application.config.graphite_endpoint)
    @taxa_page_load_time_data = g.data_for_Google_annotated_time_chart(
      'movingAverage(stats.timers.page_load_time.taxa-overview.show.mean,50)', from: DEFAULT_TIME_RANGE)
    @home_page_load_time_data = g.data_for_Google_annotated_time_chart(
      'movingAverage(stats.timers.page_load_time.content.index.mean,50)', from: DEFAULT_TIME_RANGE)
    @api_searches = g.data_for_Google_annotated_time_chart(
      'hitcount(stats.timers.page_load_time.api.search.count_ps,\'1hour\')', from: DEFAULT_TIME_RANGE)
    @slave_lag = g.data_for_Google_annotated_time_chart(
      'eol-db-slave1.mysql.general.slaveLag', from: DEFAULT_TIME_RANGE)
  end
end
