# encoding: utf-8

module Uplink
  class BitTorrentError < StandardError; end
  class Application < Sinatra::Base
    include Helpers

    error Uplink::BitTorrentError do
      { "failure reason" => env['sinatra.error'].message }.bencode
    end

    configure do
      set :show_exceptions, false

      MongoMapper.connection = Mongo::Connection.new "localhost"
      MongoMapper.database   = "uplink_development"
    end

    get "/" do
      { "failure reason" => "hejs" }.bencode
    end

    get "/:passkey/announce" do
      require_params! :info_hash, :peer_id, :port, :uploaded, :downloaded, :left, :event

      content_type "text/plain"

      if account = Account.find_by_passkey(params[:passkey])
        if torrent = Torrent.find_by_infohash(params["info_hash"])
          process torrent, account
        else
          raise BitTorrentError, "Torrent not recognized."
        end
      else
        raise BitTorrentError, "Invalid passkey."
      end
    end

  private

    def process torrent, account
      peer = torrent.torrent_peers.first peer_id: params["peer_id"]

      unless peer
        peer = TorrentPeer.new
        peer.torrent = torrent
        peer.account = account
        peer.merge_with params
        peer.save
      else
        peer.state       = params["event"]
        peer.uploaded   += params["uploaded"].to_i
        peer.downloaded += params["downloaded"].to_i
        
        peer.account.uploaded   += params["uploaded"].to_i
        peer.account.downloaded += params["downloaded"].to_i

        peer.account.save
        peer.save
      end


      case peer.state
      when "started"
      when "completed"
        snatch = TorrentSnatches.new
        snatch.torrent = torrent
        snatch.account = account
        snatch.save

        peer.destroy
      when "stopped"
        peer.destroy
      else
        raise BitTorrentError, "Unknown event"
      end
    end

    def compact_peerlist_for torrent
      
    end
  end
end
