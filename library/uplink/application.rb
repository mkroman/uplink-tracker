# encoding: utf-8

module Uplink
  class BitTorrentError < StandardError; end
  class Application < Sinatra::Base
    include Helpers, JSONAPI

    DefaultPeerListSize     = 30
    MaximumPeerListSize     = 55

    DefaultAnnounceInterval = 60
    MinimumAnnounceInterval = 50

    error Uplink::BitTorrentError do
      { "failure reason" => env['sinatra.error'].message }.bencode
    end

    error do
      { "failure reason" => "Internal error" }.bencode
    end

    not_found do
      { "failure reason" => "Invalid request" }.bencode
    end

    configure do
      set :show_exceptions, false

      MongoMapper.connection = Mongo::Connection.new "localhost"
      MongoMapper.database   = "uplink_production"
    end

    get "/:passkey/announce" do
      require_params! :info_hash, :peer_id, :port, :uploaded, :downloaded, :left
      content_type "text/plain"

      if account = Account.find_by_passkey(params[:passkey])
        if torrent = Torrent.find_by_infohash(params["info_hash"])
          announce torrent, account
        else
          raise BitTorrentError, "The requested torrent was not recognized."
        end
      else
        raise BitTorrentError, "The passkey was not recognized."
      end
    end

  private

    def announce torrent, account
      torrent.remove_ghost_peers!

      peer    = torrent.peers.first peer_id: params["peer_id"]
      compact = params["compact"] == "1"

      unless peer
        peer = TorrentPeer.new

        peer.torrent = torrent
        peer.account = account
        peer.address = env["REMOTE_ADDR"]

        peer.merge_with params

        peer.save

        puts "Peer #{peer.peer_id.inspect} relation established." ^ :bold
      else
        peer.left       = params["left"].to_i
        peer.state      = params["event"] || "leeching"
        peer.uploaded   = params["uploaded"].to_i / 1024
        peer.downloaded = params["downloaded"].to_i / 1024

        peer.save
      end

      case peer.state
      when "started"
        # …
      when "completed"
        puts "Peer #{peer.peer_id.inspect} finished leeching." ^ :bold

        TorrentSnatches.create account: account, torrent: torrent
      when "stopped"
        puts "Peer #{peer.peer_id.inspect} stopped being active." ^ :bold

        peer.destroy
      when "leeching"
        account = peer.account

        uploaded = (params["uploaded"].to_i / 1024) - peer.uploaded
        downloaded = (params["downloaded"].to_i / 1024) - peer.downloaded

        account.upload   += uploaded
        account.download += downloaded
        account.save
      else
        raise BitTorrentError, "The event that was requested is not supported."
      end

      peers = torrent.peers.all(:limit => 30).map do |peer|
        { "peer id" => peer.id, "ip" => peer.address, "port" => peer.port }
      end

      {
        "peers"        => compact ? compact!(peers) : peers,
        "interval"     => DefaultAnnounceInterval,
        "complete"     => torrent.uploaders.count,
        "incomplete"   => torrent.downloaders.count,
        "min interval" => MinimumAnnounceInterval
      }.bencode
    end
  end
end
