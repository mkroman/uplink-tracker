# encoding: utf-8

module Uplink
  class BitTorrentError < StandardError; end
  class Application < Sinatra::Base
    include Helpers

    DefaultPeerListSize     = 30
    MaximumPeerListSize     = 55

    DefaultAnnounceInterval = 60
    MinimumAnnounceInteval  = 50

    error Uplink::BitTorrentError do
      { "failure reason" => env['sinatra.error'].message }.bencode
    end

    error do
      { "failure reason" => "internal error" }.bencode
    end

    configure do
      set :show_exceptions, false

      MongoMapper.connection = Mongo::Connection.new "localhost"
      MongoMapper.database   = "uplink_development"
    end

    get "/" do
      { "failure reason" => "invalid request" }.bencode
    end

    get "/:passkey/announce" do
      require_params! :info_hash, :peer_id, :port, :uploaded, :downloaded, :left

      content_type "text/plain"

      if account = Account.find_by_passkey(params[:passkey])
        if torrent = Torrent.find_by_infohash(params["info_hash"])
          announce torrent, account
        else
          raise BitTorrentError, "Torrent not recognized."
        end
      else
        raise BitTorrentError, "Invalid passkey."
      end
    end

  private

    def announce torrent, account
      torrent.remove_ghost_peers!

      peer    = torrent.torrent_peers.first peer_id: params["peer_id"]
      compact = params["compact"] == "1"

      unless peer
        peer = TorrentPeer.new

        peer.torrent = torrent
        peer.account = account

        peer.merge_with params, env["REMOTE_ADDR"]
        peer.save
      else
        peer.left        = params["left"].to_i
        peer.state       = params["event"] || "started"
        peer.uploaded   += params["uploaded"].to_i
        peer.downloaded += params["downloaded"].to_i

        peer.save
      end

      peer.account.upload   += peer.uploaded
      peer.account.download += peer.downloaded
      peer.account.save

      puts "Peer #{peer.peer_id.inspect}: #{peer.state}"

      case peer.state
      when "started"
        # …
      when "completed"
        snatch = TorrentSnatches.new

        snatch.torrent = torrent
        snatch.account = account

        snatch.save
      when "stopped"
        peer.destroy
      else
        raise BitTorrentError, "Unknown event"
      end

      peers = torrent.torrent_peers.all(:limit => 30).map do |peer|
        { "peer id" => peer.id, "ip" => peer.address, "port" => peer.port }
      end

      {
        "peers"        => compact ? compact!(peers) : peers,
        "interval"     => 60,
        "complete"     => torrent.uploaders.count,
        "incomplete"   => torrent.downloaders.count,
        "min interval" => 50
      }.bencode
    end
  end
end
