# encoding: utf-8

module Uplink
  class Request < Rack::Request
    def method
      path.gsub /\W/, ''
    end
  end
end
