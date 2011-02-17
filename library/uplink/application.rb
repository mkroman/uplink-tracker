# encoding: utf-8

module Uplink
  class BitTorrentError < StandardError; end
  class Application < Sinatra::Base
    include Helpers

    error Uplink::BitTorrentError do
      { "failure reason" => env['sinatra.error'].message }
    end

    configure do
      MongoMapper.connection = Mongo::Connection.new 'localhost'
      MongoMapper.database   = 'uplink_development'
    end

    get "/:pass" do
      if account = Account.find_by_passkey(params[:pass])
        "found"
      else
        raise BitTorrentError, "Invalid passkey"
      end
    end
  end
end
