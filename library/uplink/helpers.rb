# encoding: utf-8

module Uplink
  module Helpers
  protected

    def require_params! *keys
      if keys.find { |key| not params.key? key.to_s }
        raise BitTorrentError, "Missing parameters! (#{params.inspect})"
      end
    end
  end
end
