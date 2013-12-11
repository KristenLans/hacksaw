require './spec/spec_helper.rb'

def stub_render_request
  url = @g.base_url + '/render/?target=' + @test_target + '&format=json'
  stub_request(:get, url).to_return(body: @test_response)
end

describe GraphiteRequest do

  before :all do
    @test_host = 'http://test.org'
    @test_target = "stats.timers.page_load_time.taxa-overview.show.mean"
    @test_response = '[{"target": "' + @test_target + '", "datapoints": [[12, 1386124320], [13, 1386124380]]}]'
    @g = GraphiteHost.new(@test_host)
    stub_render_request
    @r = GraphiteRequest.new(@g, @test_target)
  end

  before :each do
    stub_render_request
  end

  it 'should prepare_render_url' do
    expect(@r.prepare_render_url).to eq(@test_host + '/render/?target=' + @test_target + '&format=json')
  end

  it 'should fetch JSON data' do
    expect(@r.json).to eq(JSON.parse(@test_response))
  end

  it 'should fetch single values' do
    expect(@r.value).to eq(13)
  end

  it 'should fetch all all_datapoints' do
    expect(@r.all_datapoints).to eq([ [ 1386124320, 12 ], [ 1386124380, 13 ] ])
  end

  it 'should prepare data for Google annotated time charts' do
    expect(@r.data_for_Google_annotated_time_chart).to eq(
      [ 'new Date(2013, 11, 3, 21, 32, 00),12',
        'new Date(2013, 11, 3, 21, 33, 00),13' ])
  end

end

