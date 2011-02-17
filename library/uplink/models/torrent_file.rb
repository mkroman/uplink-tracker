class TorrentFile
  include MongoMapper::Document

  key :size, Bignum
  key :path, Array

  belongs_to :torrent
  
  timestamps!
end
