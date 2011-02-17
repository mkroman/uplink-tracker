class TorrentComment
  include MongoMapper::Document

  key :body,       String
  key :account_id, ObjectId
  key :torrent_id, ObjectId

  has_one :account

  belongs_to :torrent

  timestamps!
end
