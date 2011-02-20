# encoding: utf-8

require 'json'
require 'joint'
require 'majic'
require 'bcrypt'
require 'bencode'
require 'sinatra'
require 'mongo_mapper'
require 'permalink'

require 'uplink/helpers'
require 'uplink/application'

Dir.glob(File.expand_path("~/Projects/Uplink/app/models/*.rb")).each &method(:require)

module Uplink
  class << Version = [0,1]
    def to_s; join '.' end
  end

  DefaultHost = "localhost"
  DefaultPort = 6969
  
  def self.run host = DefaultHost, port = DefaultPort
    Application.run! :host => host, :port => port
  end
end
