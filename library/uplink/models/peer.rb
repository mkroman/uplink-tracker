# encoding: utf-8

module Uplink
  class Peer
    include DataMapper::Resource

    property :id,         String, length: 20, key: true
    property :port,       Integer
    property :uploaded,   Integer, min: 0, max: 2**40
    property :downloaded, Integer, min: 0, max: 2**40
    property :remaining,  Integer, min: 0, max: 2**40
    property :event,      Integer
    property :address,    String

    belongs_to :torrent
  end
end
