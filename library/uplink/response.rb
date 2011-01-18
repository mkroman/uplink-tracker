# encoding: utf-8

module Uplink
  class Response < Rack::Response
    def initialize
      @body = ""
    end

    def to_a
      [200, { "Content-Type" => "text/plain" }, @body]
    end

    def error message
      @body << { failure_reason: message }.bencode
    end

    def warn message
      @body << { warning_message: message }.bencode
    end
  end
end
