class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'application'

  DEFAULT_TIME_RANGE = '-1week'

  def index
    varnish = Varnish.latest
    @servers_online = varnish.map{|server| server['health'] == "Healthy"}.count(true)
    @servers_offline = varnish.map{|server| server['health'] == "Healthy"}.count(false)
    @servers_total = @servers_online + @servers_offline

    @taxa_page_load_time_data = GraphiteHost.connection.query(
      'movingAverage(stats.timers.page_load_time.taxa-overview.show.mean_90,50)' +
      '&target=movingAverage(stats.timers.page_load_time.taxa-overview.show.mean_90,800)', from: DEFAULT_TIME_RANGE)
    @home_page_load_time_data = GraphiteHost.connection.query(
      'movingAverage(stats.timers.page_load_time.content.index.mean_90,50)' +
      '&target=movingAverage(stats.timers.page_load_time.content.index.mean_90,800)', from: DEFAULT_TIME_RANGE)
    @api_searches = GraphiteHost.connection.query(
      'hitcount(stats.timers.page_load_time.api.search.count_ps,\'1hour\')', from: DEFAULT_TIME_RANGE)
    @recent_taxon_page_load_time = GraphiteHost.connection.query(
      'movingAverage(stats.timers.page_load_time.taxa-overview.show.mean_90,800)', from: '-1day')
    @recent_search_api_load_time = GraphiteHost.connection.query(
      'movingAverage(stats.timers.page_load_time.api.search.mean_90,800)', from: '-1day')
    @current_search_api_load_time = GraphiteHost.connection.query(
      'movingAverage(stats.timers.page_load_time.api.search.mean_90,50)', from: '-1day')
    @all_errors = GraphiteHost.connection.query('movingAverage(stats.all_errors,50)', from: DEFAULT_TIME_RANGE)
    @slave_lag = GraphiteHost.connection.query('eol-db-slave1.mysql.general.slaveLag', from: '-1minute')
  end

  def member_activity
    time_range = '-70days'
    @members_count = GraphiteHost.connection.query('movingAverage(stats.gauges.metrics.members_count,10)', from: time_range, ignore_if_nil: true)
    @content_partners = GraphiteHost.connection.query('movingAverage(stats.gauges.metrics.content_partners,10)', from: time_range, ignore_if_nil: true)
    @curators = GraphiteHost.connection.query('movingAverage(stats.gauges.metrics.curators,10)', from: time_range, ignore_if_nil: true)
    @active_curators = GraphiteHost.connection.query('movingAverage(stats.gauges.metrics.active_curators,10)', from: time_range, ignore_if_nil: true)
    @collections_count = GraphiteHost.connection.query('movingAverage(stats.gauges.metrics.collections_count,10)', from: time_range, ignore_if_nil: true)
    @communities_count = GraphiteHost.connection.query('movingAverage(stats.gauges.metrics.communities_count,10)', from: time_range, ignore_if_nil: true)
  end

end
