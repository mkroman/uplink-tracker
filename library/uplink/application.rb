# encoding: utf-8

module Uplink
  class BitTorrentError < StandardError; end
  class Application < Sinatra::Base
    include Helpers

    error Uplink::BitTorrentError do
      { "failure reason" => env['sinatra.error'].message }.bencode
    end

    configure do
      MongoMapper.connection = Mongo::Connection.new 'localhost'
      MongoMapper.database   = 'uplink_development'
    end

    get "/" do
      p env
    end

    get "/:pass" do
      require_params! :info_hash, :peer_id, :port, :uploaded, :downloaded, :left, :event

      if account = Account.find_by_passkey(params[:pass])
        if torrent = Torrent.find_by_infohash(params["info_hash"])
          process torrent, account
        else
          raise BitTorrentError, "Torrent not recognized."
        end
      else
        raise BitTorrentError, "Invalid passkey"
      end
    end
  private

    def process torrent, account
      peer = torrent.peers.where(peer_id: params["peer_id"]).first

      if peer
        if params["state"] == "started"
          # …
        end
      else
        peer = TorrentPeer.new peer_id: params["peer_id"]
        peer.port    = params["port"]
        peer.left    = params["left"]
        peer.state   = params["state"]
        peer.address = env['REMOTE_ADDR']
        peer.torrent = torrent
        peer.account = account

        peer.uploaded   = params["uploaded"]
        peer.downloaded = params["downloaded"]
        peer.save
      end
    end
  end
end
