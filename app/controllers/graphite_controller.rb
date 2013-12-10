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
    render json: matches[0..100].collect{ |metric| {
      id: metric,
      value: metric,
      label: metric }}.to_json
  end

  def custom
    @original_target = params[:target]
    @original_target2 = params[:target2]
    @target = @original_target.dup
    @target2 = @original_target2.dup
    @from = params[:from] ||= "-1day"
    @to = params[:to]
    @interval = params[:interval]
    unless @target.blank?
      unless @interval.blank?
        @target = "movingAverage(#{@target},#{@interval})"
        @target2 = "movingAverage(#{@target2},#{@interval})" unless @target2.blank?
      end
      @target << "&target=#{@target2}" unless @target2.blank?
      g = Graphite.new(Hacksaw::Application.config.graphite_endpoint)
      @chart_data = g.data_for_Google_annotated_time_chart(@target, from: @from, to: @to)
    end
  end

end
