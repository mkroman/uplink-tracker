class Account
  include MongoMapper::Document
  attr_accessor :password, :password_confirmation

  # Keys
  key :name,             String
  key :email,            String
  key :upload,           Bignum, default: 1_048_576 # kilobytes
  key :passkey,          String
  key :download,         Bignum, default: 524_248 # kilobytes
  key :crypted_password, String
  key :role,             String

  # Relations
  has_many :torrents
  has_many :torrent_comments
  has_many :torrent_snatches
  has_many :torrent_peers

  validates_presence_of     :name, :email, :role
  validates_presence_of     :password,                   :if => :password_required
  validates_presence_of     :password_confirmation,      :if => :password_required
  validates_length_of       :password, :within => 4..40, :if => :password_required
  validates_confirmation_of :password,                   :if => :password_required
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_format_of       :role,     :with => /[A-Za-z]/

  before_save :generate_password
  before_save :generate_passkey

  def self.authenticate email, password
    account = first(email: email) if email.present?
    account && account.has_password?(password) ? account : nil
  end

  def has_password? password
    ::BCrypt::Password.new(crypted_password) == password
  end

  def ratio
    (upload.to_f / download.to_f).round 3
  end

private

  def generate_passkey
    unless self.passkey
      self.passkey = Digest::MD5.hexdigest [Time.now.to_i, rand(36 ** 15).to_s(36)].join
    end
  end

  def generate_password
    self.crypted_password = ::BCrypt::Password.create password
  end

  def password_required
    crypted_password.blank? or !password.blank?
  end
end
