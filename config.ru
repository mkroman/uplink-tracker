#!/usr/bin/env ruby
# encoding: utf-8

$:.unshift File.dirname(__FILE__) + '/library'
require 'uplink'

run Uplink::Application
