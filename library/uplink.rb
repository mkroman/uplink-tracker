# encoding: utf-8

require 'bencode'
require 'sinatra'
require 'mongo_mapper'

require 'uplink/application'

module Uplink
  class << Version = [0,1]
    def to_s; join '.' end
  end

  DefaultHost = 'localhost'
  DefaultPort = 6969
  
  def self.run
    Application.run! :host => DefaultHost, :port => DefaultPort
  end
end
