class TorrentSnatch
  include MongoMapper::Document

  # Relations
  belongs_to :account
  belongs_to :torrent

  timestamps!
end
