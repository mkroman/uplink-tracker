class Torrent
  include MongoMapper::Document
  plugin Permalink
  plugin Joint

  key :name,        String
  key :size,        Bignum
  key :description, String

  key :genre_id,    ObjectId
  key :account_id,  ObjectId
 
  permalink :name

  # Relations
  belongs_to :account
  belongs_to :genre

  has_many :torrent_comments
  has_many :torrent_snatches
  has_many :torrent_files
  has_many :torrent_peers

  has_one :torrent_IMDB

  attachment :metadata
  attachment :nfo

  after_save :read_metadata

  timestamps!

  def metadata_for account
    data = BEncode.load metadata.read
    data["announce"] = "http://phi.uplink.io/#{account.passkey}"
    data.bencode
  end

  def uploaders
    torrent_peers.where state: :completed
  end

  def downloaders
    torrent_peers.where state: :started
  end

private
  def read_metadata
    if metadata and not torrent_files.any?
      data = BEncode.load metadata.read

      data["info"]["files"].each do |file|
        self.torrent_files.<< TorrentFile.new size: file['length'], path: file['path']
      end

      self.size = (self.torrent_files.map(&:size).inject(?+) / 1024)

      save
    end
  end

  alias :imdb  :torrent_IMDB
  alias :imdb= :torrent_IMDB=
end
