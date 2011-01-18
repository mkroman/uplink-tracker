# encoding: utf-8

module Uplink
  class Server

    DefaultHost = '0.0.0.0'
    DefaultPort = 6969

    def initialize host = DefaultHost, port = DefaultPort
      @host, @port, @tracker = host, port, Tracker.new
    end

    def start
      DataMapper.setup :default, "mysql://root:php9931@localhost/uplink"
      DataMapper.auto_migrate!

      Rack::Handler::Thin.run self, Host: @host, Port: @port
    end

    def call environment
      request = Request.new environment
       method = :"got_#{request.method}"

      if @tracker.respond_to? method
        @tracker.__send__ method, request
      else
        [404, {}, "d14:failure reason15:invalid requeste"]
      end
    rescue Exception => exception
      [500, {}, "d14:failure reason#{exception.message.bencode}e"]
    end
  end
end
