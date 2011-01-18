# encoding: utf-8

module Uplink
  class Torrent
    include DataMapper::Resource

    property :id,          Serial
    property :name,        String, length: 255
    property :info_hash,   String, length: 20
    property :description, Text

    has n, :peers

    def self.with_info_hash hash
      first info_hash: hash
    end
  end
end
