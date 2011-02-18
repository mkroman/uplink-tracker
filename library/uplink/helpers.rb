# encoding: utf-8

module Uplink
  module Helpers
  protected

    def require_params! *keys
      if keys.find { |key| not params.key? key.to_s }
        raise BitTorrentError, "Missing parameters! (#{params.inspect})"
      end
    end

    def compact! peers
      peers.map do |peer|
        host = peer["ip"].split(?.).collect(&:to_i).pack 'C*'
        port = [peer["port"]].pack 'n*'

        [host, port].join
      end.join
    end

    def memory_usage
       %x{ps -o rss= -p #{Process.pid}}.to_f / 1024.0
    end

  end
end
