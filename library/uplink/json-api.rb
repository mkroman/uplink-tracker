# encoding: utf-8

module Uplink
  module JSONAPI
    def self.included klass
      klass.class_eval do
        get "/stats.json" do
          content_type "application/json"

          { peers: TorrentPeer.count, memory: memory_usage }.to_json
        end
      end
    end
  end
end
