# encoding: utf-8

require 'rack'
require 'datamapper'

Dir.glob("#{File.dirname __FILE__}/uplink/**/*.rb").map &method(:require)

module Uplink
  class << Version = [0,1]
    def to_s; join '.' end
  end

module_function

  def start *args
    Server.new(*args).tap do |this|
      yield this if block_given?
    end.start
  end
end
