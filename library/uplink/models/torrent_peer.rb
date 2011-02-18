class TorrentPeer
  include MongoMapper::Document

  key :left,       Fixnum
  key :port,       Fixnum
  key :state,      String, default: :started
  key :peer_id,    String
  key :address,    String
  key :uploaded,   Fixnum
  key :downloaded, Fixnum

  belongs_to :torrent
  belongs_to :account
  
  timestamps!

  def merge_with params, address
    self.left       = params["left"].to_i
    self.port       = params["port"].to_i
    self.state      = params["event"] || "started"
    self.peer_id    = params["peer_id"]
    self.address    = address
    self.uploaded   = params["uploaded"].to_i / 1024
    self.downloaded = params["downloaded"].to_i / 1024
  end
end
