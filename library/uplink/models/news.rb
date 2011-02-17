class News
  include MongoMapper::Document
  plugin Permalink

  key :title,      String
  key :body,       String
  key :account_id, ObjectId

  permalink :title

  timestamps!

  belongs_to :account
end
