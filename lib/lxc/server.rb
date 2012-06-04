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

      def find_container
        @container = LXC.container(params[:c_name])
        unless @container.exists?
          error_response("Container #{name} does not exist")
        end
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
      content_type :json, :encoding => :utf8
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

    get '/containers/:c_name' do
      find_container
      json_response(@container.to_hash)
    end

    post '/containers/:c_name/:action' do
      find_container
      case params[:action]
      when 'start', 'stop', 'freeze', 'unfreeze'
        @container.send(params[:action].to_sym)
      else
        error_response("Invalid action: #{params[:action]}")
      end
      json_response(@container.to_hash)
    end
  end
end