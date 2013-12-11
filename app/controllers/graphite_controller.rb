class GraphiteController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'application'

  def autocomplete_metrics
    term = params[:term]
    matches = GraphiteHost.connection.all_possible_metrics
    term.split(' ').each do |term|
      matches = matches.select{ |m| m.include?(term) }
    end
    render json: matches[0..100].collect{ |metric| {
      id: metric,
      value: metric,
      label: metric }}.to_json
  end

  def custom
    @chart_url = request.original_url
    @original_target = params[:target]
    @original_target2 = params[:target2]
    if matches = @original_target.match(/(.*)&target=(.*)/)
      @original_target = matches[1]
    end
    @target = @original_target.dup
    @target2 = @original_target2.nil? ? nil: @original_target2.dup
    @from = params[:from] ||= "-7day"
    @to = params[:to]
    @interval = params[:interval]
    unless @target.blank?
      unless @interval.blank?
        @target = "movingAverage(#{@target},#{@interval})" unless @target.include?('movingAverage')
        @target2 = "movingAverage(#{@target2},#{@interval})" unless @target2.blank? || @target2.include?('movingAverage')
      end
      @target << "&target=#{@target2}" unless @target2.blank?
      @graphite_request = GraphiteHost.connection.query(@target, from: @from, to: @to)
    end
  end

end
