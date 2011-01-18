# encoding: utf-8

require 'rack'
require 'bencoding'

Dir.glob("#{File.dirname __FILE__}/uplink/**/*.rb").map &method(:require)

module Uplink
  class << Version = [0,1]
    def to_s; join '.' end
  end
end
