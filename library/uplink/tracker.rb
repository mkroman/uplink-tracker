# encoding: utf-8

module Uplink
  class Tracker
    RequiredParameters = %w{info_hash peer_id port uploaded downloaded left compact event}
    
    def got_announce request
      unless request.params.keys.has? *RequiredParameters
        raise ArgumentError, RequiredParameters - request.params.keys
      end
      
      respond do
        error "Sorry bro' :<"
      end
      
    rescue ArgumentError => exception
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
