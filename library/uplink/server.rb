# encoding: utf-8

module Uplink
  class Server
    DefaultHost = '0.0.0.0'
    DefaultPort = 6969
    
    attr_accessor :host, :port, :tracker
    
    def initialize host = DefaultHost, port = DefaultPort
      @host = host
      @port = port
      
      @tracker = Tracker.new
    end
    
    def start
      # TODO: Connect to mongod …
      
      Rack::Handler::Thin.run self, Host: @host, Port: @port
    end
    
    def call environment
      request = Request.new environment
       method = :"got_#{request.method}"
       
      if @tracker.respond_to? method
        @tracker.__send__ method, request
      else
        [404, {}, { failure_reason: "invalid request" }.bencode]
      end
    rescue Exception => exception
      [500, {}, { failure_reason: "#{exception.message}" }]
    end
  end
end
