class TorrentIMDB
  include MongoMapper::Document

  key :plot,     String
  key :name,     String
  key :date,     String
  key :stars,    Array
  key :poster,   String
  key :genres,   Array
  key :runtime,  String
  key :director, String
  
  timestamps!
end
