require './spec/spec_helper.rb'
describe Graphite do

  before :all do
    @test_host = 'http://test.org'
    @test_target = "stats.timers.page_load_time.taxa-overview.show.mean"
    @test_response = '[{"target": "' + @test_target + '", "datapoints": [[12, 1386124320], [13, 1386124380]]}]'
    @g = Graphite.new(@test_host)
  end

  it "should initialize graphite_url" do
    expect(@g.graphite_url).to eq(@test_host)
  end

  it 'should prepare_url' do
    expect(@g.prepare_url(@test_target)).to eq(@test_host + '/render/?target=' + @test_target + '&format=json')
  end

  it 'should fetch JSON data' do
    stub_request(:get, @g.prepare_url(@test_target)).to_return(:body => @test_response)
    expect(@g.json(@test_target)).to eq(JSON.parse(@test_response))
  end

  it 'should fetch single values' do
    stub_request(:get, @g.prepare_url(@test_target)).to_return(:body => @test_response)
    expect(@g.value(@test_target)).to eq(13)
  end

  it 'should fetch all datapoints' do
    stub_request(:get, @g.prepare_url(@test_target)).to_return(:body => @test_response)
    expect(@g.datapoints(@test_target)).to eq(JSON.parse(@test_response).first['datapoints'])
  end

  it 'should prepare data for Google annotated time charts' do
    stub_request(:get, @g.prepare_url(@test_target)).to_return(:body => @test_response)
    expect(@g.data_for_Google_annotated_time_chart(@test_target)).to eq(
      [ { date: "new Date(2013, 12, 3, 21, 32, 00)", value: 12 },
        { date: "new Date(2013, 12, 3, 21, 33, 00)", value: 13 }
      ])
  end

end

