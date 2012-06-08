require 'spec_helper'

describe LXC::Server do
  it 'GET / returns some data' do
    get '/'
    last_response.status.should eq(200)
    last_response.headers['Content-Type'].should match('application/json')
    last_response.headers['Content-Type'].should match('utf8')
    last_response.body.should_not be_empty
  end

  it 'GET /version returns gem version' do
    get '/version'
    last_response.should be_ok
    parse_json(last_response.body)['version'].should eq(LXC::VERSION)
  end

  it 'GET /lxc_version returns installed LXC version' do
    stub_lxc('version') { fixture('lxc-version.txt') }

    get '/lxc_version'
    last_response.should be_ok
    parse_json(last_response.body)['version'].should eq('0.7.5')
  end

  it 'GET /containers returns a list of containers' do
    stub_lxc('ls') { "app" }
    stub_lxc('info', '-n', 'app') { fixture('lxc-info-running.txt') }

    get '/containers'
    last_response.should be_ok
    
    data = parse_json(last_response.body)
    data.should be_an Array
    data.should_not be_empty
    data.first.keys.should eq(['name', 'state', 'pid'])
  end

  it 'GET /container/:name returns a single container' do
    stub_lxc('ls') { "app" }
    stub_lxc('info', '-n', 'app') { fixture('lxc-info-running.txt') }

    get '/containers/app'
    last_response.should be_ok

    data = parse_json(last_response.body)
    data.should be_a Hash
    data.should_not be_empty
    data['name'].should eq('app')
    data['state'].should eq('RUNNING')
    data['pid'].should eq('2125')
  end

  context 'Errors' do
    class LXC::Server
      get '/exception' do
        raise RuntimeError, "Something went wrong"
      end
    end

    it 'renders error message on non-existent route' do
      get '/foo-bar'
      last_response.should_not be_ok
      last_response.status.should eq(404)
      parse_json(last_response.body)['error'].should eq('Invalid request path')
    end

    it 'renders exception message on internal server error' do
      get '/exception'
      last_response.should_not be_ok
      last_response.status.should eq(500)
      data = parse_json(last_response.body)
      data.should be_a Hash
      data.should_not be_empty
      data['error'].should_not be_nil
      data['error']['message'].should eq('Something went wrong')
      data['error']['type'].should eq('RuntimeError')
    end
  end
end