class TorrentPeer
  include MongoMapper::Document

  key :state, String, default: :started
  key :address, String
  
  timestamps!
end
