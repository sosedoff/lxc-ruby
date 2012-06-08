require 'spec_helper'

describe LXC::Server do
  it 'GET / returns some data' do
    get '/'
    last_response.status.should eq(200)
    last_response.headers['Content-Type'].should eq('application/json;encoding=utf8, charset=utf-8')
    last_response.body.should_not be_empty
  end

  it 'GET /version returns gem version' do
    get '/version'
    last_response.should be_ok
    parse_json(last_response.body)['version'].should eq(LXC::VERSION)
  end

  it 'GET /lxc_version returns installed LXC version' do
    stub_lxc_with_fixture('version', 'lxc-version.txt')

    get '/lxc_version'
    last_response.should be_ok
    parse_json(last_response.body)['version'].should eq('0.7.5')
  end

  it 'GET /containers returns a list of containers' do
    get '/containers'
    last_response.should be_ok
    data = parse_json(last_response.body)

    data.should be_an Array
    data.should_not be_empty
    data.first.keys.should eq(['name', 'state', 'pid'])
  end

  it 'GET /container/:name returns a single container' do
    get '/containers/app'
    last_response.should be_ok
    data = parse_json(last_response.body)

    data.should be_a Hash
    data.should_not be_empty
    data['name'].should eq('app')
    data['status'].should eq('RUNNING')
    data['pid'].should eq('2125')
  end
end