# encoding: utf-8

require 'json'
require 'joint'
require 'bencode'
require 'sinatra'
require 'mongo_mapper'
require 'permalink'

require 'uplink/helpers'
require 'uplink/application'

Dir.glob(File.join(File.dirname(__FILE__), 'uplink/models', '*.rb')).each &method(:require)

module Uplink
  class << Version = [0,1]
    def to_s; join '.' end
  end

  DefaultHost = "localhost"
  DefaultPort = 6969
  
  def self.run
    Application.run! :host => DefaultHost, :port => DefaultPort
  end
end
