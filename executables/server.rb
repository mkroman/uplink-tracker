#!/usr/bin/env ruby
# encoding: utf-8

$:.unshift File.dirname(__FILE__) + '/../library'
require 'uplink'

Host = '0.0.0.0'
Port = 6969

Uplink::Server.new(Host, Port).tap do |this|
  puts "==> Uplink #{Uplink::Version}"
end.start