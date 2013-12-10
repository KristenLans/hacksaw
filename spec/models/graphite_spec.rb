require './spec/spec_helper.rb'

def stub_render_request
  stub_request(:get, @g.prepare_render_url(@test_target)).to_return(body: @test_response)
end

def stub_metrics_request
  stub_request(:get, @g.graphite_url + '/metrics/index.json').to_return(body: @test_metrics_response)
end

describe Graphite do

  before :all do
    @test_host = 'http://test.org'
    @test_target = "stats.timers.page_load_time.taxa-overview.show.mean"
    @test_response = '[{"target": "' + @test_target + '", "datapoints": [[12, 1386124320], [13, 1386124380]]}]'
    @test_metrics_response = '[".stats.timers.page_load_time.taxa-overview.show.mean", ".stats.timers.page_load_time.taxa-overview.show.mean_90"]'
    @g = Graphite.new(@test_host)
  end

  it "should initialize graphite_url" do
    expect(@g.graphite_url).to eq(@test_host)
  end

  it 'should prepare_render_url' do
    expect(@g.prepare_render_url(@test_target)).to eq(@test_host + '/render/?target=' + @test_target + '&format=json')
  end

  it 'should fetch JSON data' do
    stub_render_request
    expect(@g.json(@test_target)).to eq(JSON.parse(@test_response))
  end

  it 'should fetch single values' do
    stub_render_request
    expect(@g.value(@test_target)).to eq(13)
  end

  it 'should fetch all all_datapoints' do
    stub_render_request
    expect(@g.all_datapoints(@test_target)).to eq([ [ 1386124320, 12 ], [ 1386124380, 13 ] ])
  end

  it 'should prepare data for Google annotated time charts' do
    stub_render_request
    expect(@g.data_for_Google_annotated_time_chart(@test_target)).to eq(
      [ 'new Date(2013, 11, 3, 21, 32, 00),12',
        'new Date(2013, 11, 3, 21, 33, 00),13' ])
  end

  it 'should prepare data for Google annotated time charts' do
    stub_metrics_request
    expect(@g.all_possible_metrics).to eq(
      [ 'stats.timers.page_load_time.taxa-overview.show.mean',
        'stats.timers.page_load_time.taxa-overview.show.mean_90'
      ])
  end

end

