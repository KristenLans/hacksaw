class TestsController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def google
    title = params[:title] || 'Chart Title'
    g = Graphite.new(Hacksaw::Application.config.graphite_endpoint)
    chart_data = g.data_for_Google_annotated_time_chart(params[:target], from: params[:from], to: params[:to])
    render :partial => 'google_charts/annotated_time', locals: { chart_data: chart_data,
      title: title, width: 700, height: 300 }
  end
end
