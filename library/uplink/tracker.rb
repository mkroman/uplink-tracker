# encoding: utf-8

module Uplink
  class Tracker
    class MissingParameter < StandardError; end

    RequiredParameters = %w{info_hash peer_id port uploaded downloaded left compact event}

    def initialize
      # …
    end

    def got_announce request
      unless request.params.keys.has? *RqeuiredParameters
        raise MissingParameter, RequiredParameters - request.params.keys
      end

      if torrent = Torrent.with_info_hash(request[:info_hash])

      else
        respond { error "No such torrent on this tracker." }
      end
    rescue MissingParameter => exception
      respond { error "#{exception.class.name}: #{exception.message}" }
    end

  private

    def respond &block
      Response.new.tap do |this|
        this.instance_eval &block
      end.to_a
    end
  end
end
