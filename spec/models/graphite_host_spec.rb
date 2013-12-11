require './spec/spec_helper.rb'

def stub_metrics_request
  test_response = '[".stats.timers.page_load_time.taxa-overview.show.mean", ".stats.timers.page_load_time.taxa-overview.show.mean_90"]'
  stub_request(:get, @g.base_url + '/metrics/index.json').to_return(body: test_response)
end

describe GraphiteHost do

  before :all do
    @test_host = 'http://test.org'
    @g = GraphiteHost.new(@test_host)
  end

  it "should initialize" do
    expect(@g.base_url).to eq(@test_host)
  end

  it 'should prepare data for Google annotated time charts' do
    stub_metrics_request
    expect(@g.all_possible_metrics).to eq(
      [ 'stats.timers.page_load_time.taxa-overview.show.mean',
        'stats.timers.page_load_time.taxa-overview.show.mean_90'
      ])
  end

end

