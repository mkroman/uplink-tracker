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
end
