require 'sinatra/base'
require 'multi_json'

module LXC
  class Server < Sinatra::Base
    set :environment, ENV['RACK_ENV'] || 'production'

    helpers do
      def json_response(data)
        MultiJson.encode(data)
      end
      
      def error_response(error, status=400)
        halt(400, json_response(:error => error))
      end
    end
    
    before do
      content_type :json, :encoding => :utf8
    end
    
    error do
      err = env['sinatra.error']
      content_type :json, :encoding => :utf8
      json_response(:error => {:message => err.message, :type => err.class.to_s})
    end
    
    not_found do
      json_response(:error => "Invalid request path")
    end
    
    get '/' do
      json_response({'time' => Time.now})
    end
    
    get '/version' do
      json_response('version' => LXC::VERSION)
    end

    get '/lxc_version' do
      json_response('version' => LXC.version)
    end

    get '/containers' do
      containers = LXC.containers
      json_response(containers.map(&:to_hash))
    end

    get '/containers/:name' do
      container = LXC.container(params[:name])
      json_response(container.to_hash)
    end
  end
end