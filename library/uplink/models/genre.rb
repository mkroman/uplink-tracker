class Genre
  include MongoMapper::Document

  key :name, String
  key :icon, String

  has_many :torrents
  
  timestamps!
end
