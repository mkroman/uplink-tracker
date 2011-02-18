class Torrent
  include MongoMapper::Document
  plugin Permalink
  plugin Joint

  key :name,        String
  key :size,        Bignum
  key :infohash,    String
  key :description, String

  permalink :name

  # Relations
  belongs_to :account
  belongs_to :torrent_genre

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
    data["announce"] = "http://phi.uplink.io:6969/#{account.passkey}/announce"
    data.bencode
  end

  def uploaders
    torrent_peers.where left: 0
  end

  def downloaders
    torrent_peers.where :state => "started", :left.gt => 0
  end

  def remove_ghost_peers!
    torrent_peers.where(:updated_at.lt => Time.now - 120).all.each(&:delete)
  end

private

  def read_metadata
    if metadata and not torrent_files.any?
      data = BEncode.load metadata.read

      data["info"]["files"].each do |file|
        self.torrent_files.<< TorrentFile.new size: file['length'], path: file['path']
      end

      self.size = (self.torrent_files.map(&:size).inject(?+) / 1024)
      self.infohash = Digest::SHA1.digest data["info"].bencode

      save
    end
  end

  alias :imdb   :torrent_IMDB
  alias :imdb=  :torrent_IMDB=
  alias :genre  :torrent_genre
  alias :genre= :torrent_genre=
end
