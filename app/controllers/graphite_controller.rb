class GraphiteController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'application'

  def autocomplete_metrics
    term = params[:term]
    g = Graphite.new(Hacksaw::Application.config.graphite_endpoint)
    matches = g.all_possible_metrics
    term.split(' ').each do |term|
      matches = matches.select{ |m| m.include?(term) }
    end
    render :json => matches[0..100].collect{ |metric| {
      :id => metric,
      :value => metric,
      :label => metric }}.to_json
  end

  def custom
    @target = params[:target]
    @from = params[:from] ||= "-1day"
    @to = params[:to]
    @interval = params[:interval]
    raise unless @target
    @search_target = @target
    if @interval && ! @search_target.include?('movingAverage')
      @search_target = "movingAverage(#{@search_target},#{@interval})"
    end
    g = Graphite.new(Hacksaw::Application.config.graphite_endpoint)
    @chart_data = g.data_for_Google_annotated_time_chart(@search_target, from: @from, to: @to)
  end

end
